-- TOFAN AI: server-only, one-time owner bootstrap gate.
-- This migration creates a disabled bootstrap state. It does NOT assign an owner.
-- Do not enable the state until the server secret has been set out-of-band and
-- the deployment operator has verified the intended Supabase Auth account.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to service_role;

create table if not exists private.tofan_owner_registry (
  singleton boolean primary key default true check (singleton),
  owner_user_id uuid not null unique references auth.users(id) on delete restrict,
  assigned_at timestamptz not null default now(),
  assigned_via text not null check (assigned_via = 'one_time_server_bootstrap')
);

create table if not exists private.tofan_owner_bootstrap_state (
  singleton boolean primary key default true check (singleton),
  armed boolean not null default false,
  consumed_at timestamptz,
  consumed_by uuid references auth.users(id) on delete restrict,
  constraint tofan_owner_bootstrap_consumption_pair
    check ((consumed_at is null and consumed_by is null)
        or (consumed_at is not null and consumed_by is not null))
);

create table if not exists private.tofan_owner_bootstrap_audit (
  id bigint generated always as identity primary key,
  attempted_user_id uuid references auth.users(id) on delete set null,
  outcome text not null check (outcome in ('owner_assigned', 'rejected')),
  reason text not null,
  occurred_at timestamptz not null default now()
);

insert into private.tofan_owner_bootstrap_state (singleton, armed)
values (true, false)
on conflict (singleton) do nothing;

revoke all on private.tofan_owner_registry from public, anon, authenticated, service_role;
revoke all on private.tofan_owner_bootstrap_state from public, anon, authenticated, service_role;
revoke all on private.tofan_owner_bootstrap_audit from public, anon, authenticated, service_role;

create or replace function public.consume_tofan_owner_bootstrap(p_user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, private, auth
as $function$
declare
  v_armed boolean;
  v_consumed_at timestamptz;
begin
  if p_user_id is null then
    return false;
  end if;

  -- Lock the singleton row so concurrent requests cannot both consume it.
  select armed, consumed_at
    into v_armed, v_consumed_at
    from private.tofan_owner_bootstrap_state
   where singleton = true
   for update;

  if not found or not v_armed or v_consumed_at is not null then
    insert into private.tofan_owner_bootstrap_audit
      (attempted_user_id, outcome, reason)
    values (p_user_id, 'rejected', 'bootstrap_not_armed_or_already_consumed');
    return false;
  end if;

  if exists (select 1 from private.tofan_owner_registry where singleton = true) then
    insert into private.tofan_owner_bootstrap_audit
      (attempted_user_id, outcome, reason)
    values (p_user_id, 'rejected', 'owner_already_exists');
    return false;
  end if;

  insert into private.tofan_owner_registry
    (singleton, owner_user_id, assigned_via)
  values (true, p_user_id, 'one_time_server_bootstrap');

  update private.tofan_owner_bootstrap_state
     set armed = false,
         consumed_at = clock_timestamp(),
         consumed_by = p_user_id
   where singleton = true
     and armed = true
     and consumed_at is null;

  if not found then
    raise exception 'Owner bootstrap state changed unexpectedly';
  end if;

  insert into private.tofan_owner_bootstrap_audit
    (attempted_user_id, outcome, reason)
  values (p_user_id, 'owner_assigned', 'one_time_server_bootstrap_consumed');

  return true;
exception
  when unique_violation then
    -- A unique constraint is a final race-condition guard. The transaction
    -- rolls back the partial assignment and the caller receives a safe denial.
    return false;
end;
$function$;

revoke all on function public.consume_tofan_owner_bootstrap(uuid)
  from public, anon, authenticated;
grant execute on function public.consume_tofan_owner_bootstrap(uuid)
  to service_role;
