-- TOFAN owner bootstrap: single-use, server-only, and gated on reviewed identity.
-- This migration is a proposal until reviewed and explicitly applied.
-- The bootstrap secret exists only as an Edge Function secret; it is never stored here.

create table if not exists public.tofan_owner_assignment (
  singleton boolean primary key default true check (singleton),
  owner_user_id uuid not null unique references auth.users(id) on delete restrict,
  assigned_at timestamptz not null default now(),
  assignment_method text not null check (assignment_method = 'verified_bootstrap')
);

alter table public.tofan_owner_assignment enable row level security;
revoke all on table public.tofan_owner_assignment from anon, authenticated;
grant select on table public.tofan_owner_assignment to service_role;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to service_role;

create table if not exists private.tofan_owner_bootstrap_state (
  singleton boolean primary key default true check (singleton),
  consumed_at timestamptz,
  consumed_by uuid references auth.users(id) on delete restrict
);

insert into private.tofan_owner_bootstrap_state (singleton, consumed_at, consumed_by)
values (true, null, null)
on conflict (singleton) do nothing;

revoke all on table private.tofan_owner_bootstrap_state from public, anon, authenticated;
grant select, update on table private.tofan_owner_bootstrap_state to service_role;

create or replace function public.claim_initial_tofan_owner(p_actor_id uuid)
returns table (owner_user_id uuid, assigned_at timestamptz)
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $function$
declare
  v_assigned_at timestamptz;
begin
  if p_actor_id is null then
    raise exception 'authenticated actor is required' using errcode = '22023';
  end if;

  -- Identity must have been explicitly reviewed by a trusted reviewer/provider.
  if not exists (
    select 1
    from public.identity_verification_requests iv
    where iv.user_id = p_actor_id
      and iv.status = 'verified'
      and (
        (iv.method = 'manual_document_review'
          and iv.assurance_level = 'document_reviewed'
          and iv.reviewer_actor_id is not null)
        or
        (iv.method = 'trusted_provider'
          and iv.assurance_level = 'provider_verified'
          and iv.provider_reference is not null)
      )
  ) then
    raise exception 'identity verification is required before owner bootstrap'
      using errcode = '42501';
  end if;

  -- Atomic single-use consumption: concurrent callers cannot both win.
  update private.tofan_owner_bootstrap_state
     set consumed_at = now(), consumed_by = p_actor_id
   where singleton = true and consumed_at is null;
  if not found then
    raise exception 'owner bootstrap is already consumed or unavailable'
      using errcode = '23505';
  end if;

  insert into public.tofan_owner_assignment as assigned_owner
    (singleton, owner_user_id, assignment_method)
  values (true, p_actor_id, 'verified_bootstrap')
  returning assigned_owner.assigned_at into v_assigned_at;

  return query select p_actor_id, v_assigned_at;
end;
$function$;

revoke all on function public.claim_initial_tofan_owner(uuid) from public, anon, authenticated;
grant execute on function public.claim_initial_tofan_owner(uuid) to service_role;

comment on table public.tofan_owner_assignment is
  'Canonical single-owner assignment. Client roles have no direct access; trusted server operations must check this table.';
comment on function public.claim_initial_tofan_owner(uuid) is
  'Service-role-only atomic bootstrap RPC. Call only after Edge Function validates the one-time bootstrap secret and Supabase JWT.';
