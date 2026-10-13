-- TOFAN ID: passkey credentials and single-use WebAuthn ceremony challenges.
-- Server-side step-up only; this migration does not create a Supabase Auth session from a passkey.
-- Credential public keys are not biometric templates; private keys remain in the authenticator.

create table if not exists public.tofan_passkey_credentials (
  credential_id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  public_key_base64 text not null,
  sign_count bigint not null default 0 check (sign_count >= 0),
  transports text[] not null default '{}',
  device_type text not null check (device_type in ('singleDevice', 'multiDevice')),
  backed_up boolean not null default false,
  created_at timestamptz not null default now(),
  last_used_at timestamptz
);

create index if not exists idx_tofan_passkey_credentials_user
  on public.tofan_passkey_credentials (user_id);

alter table public.tofan_passkey_credentials enable row level security;
revoke all on table public.tofan_passkey_credentials from anon, authenticated;
grant select, insert, update, delete on table public.tofan_passkey_credentials to service_role;

create table if not exists public.tofan_passkey_challenges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  ceremony text not null check (ceremony in ('registration', 'authentication')),
  challenge text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '5 minutes'),
  consumed_at timestamptz
);

create index if not exists idx_tofan_passkey_challenges_user
  on public.tofan_passkey_challenges (user_id, ceremony, expires_at desc);

alter table public.tofan_passkey_challenges enable row level security;
revoke all on table public.tofan_passkey_challenges from anon, authenticated;
grant select, insert, update, delete on table public.tofan_passkey_challenges to service_role;

comment on table public.tofan_passkey_credentials is
  'Server-verified WebAuthn public credential material only; no fingerprint or face template is stored.';
comment on table public.tofan_passkey_challenges is
  'Short-lived, single-use WebAuthn challenges; inaccessible to anon/authenticated client database roles.';


create table if not exists public.tofan_owner_step_up_grants (
  token_hash text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  scope text not null check (scope = 'owner_operation'),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  consumed_at timestamptz
);

create index if not exists idx_tofan_owner_step_up_grants_user_expiry
  on public.tofan_owner_step_up_grants (user_id, expires_at desc);

alter table public.tofan_owner_step_up_grants enable row level security;
revoke all on table public.tofan_owner_step_up_grants from anon, authenticated;
grant select, insert, update, delete on table public.tofan_owner_step_up_grants to service_role;

create or replace function public.consume_tofan_owner_step_up(
  p_actor_id uuid,
  p_token_hash text
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, public
as $function$
begin
  if p_actor_id is null or p_token_hash is null or length(p_token_hash) <> 64 then
    return false;
  end if;

  if not exists (
    select 1 from public.tofan_owner_assignment oa
    where oa.singleton = true and oa.owner_user_id = p_actor_id
  ) then
    return false;
  end if;

  update public.tofan_owner_step_up_grants g
     set consumed_at = now()
   where g.token_hash = p_token_hash
     and g.user_id = p_actor_id
     and g.scope = 'owner_operation'
     and g.consumed_at is null
     and g.expires_at > now();

  return found;
end;
$function$;

revoke all on function public.consume_tofan_owner_step_up(uuid, text) from public, anon, authenticated;
grant execute on function public.consume_tofan_owner_step_up(uuid, text) to service_role;

comment on table public.tofan_owner_step_up_grants is
  'Short-lived, one-time server-verifiable step-up receipts; store only SHA-256 hashes, never raw tokens.';
comment on function public.consume_tofan_owner_step_up(uuid, text) is
  'Service-role-only atomic consumption; succeeds only for the current canonical owner and a live unused grant.';
