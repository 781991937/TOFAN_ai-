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
