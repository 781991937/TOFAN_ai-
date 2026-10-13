-- TOFAN ID: privacy-minimized verification request metadata.
-- This migration is for review only; it has NOT been applied to any database.
-- No identity-card image, full card number, OCR payload, or face template is stored.

create table if not exists public.identity_verification_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending_review'
    check (status in ('pending_review', 'verified', 'rejected', 'suspended')),
  method text not null
    check (method in ('manual_document_review', 'trusted_provider')),
  assurance_level text not null default 'none'
    check (assurance_level in ('none', 'document_reviewed', 'provider_verified')),
  reviewer_actor_id uuid references auth.users(id) on delete set null,
  provider_reference text,
  reason_code text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  reviewed_at timestamptz,
  constraint identity_verification_status_assurance_check check (
    (status = 'pending_review' and assurance_level = 'none' and reviewed_at is null)
    or (status = 'verified' and assurance_level in ('document_reviewed', 'provider_verified') and reviewed_at is not null)
    or (status in ('rejected', 'suspended') and reviewed_at is not null)
  )
);

create index if not exists idx_identity_verification_user_created
  on public.identity_verification_requests (user_id, created_at desc);

alter table public.identity_verification_requests enable row level security;

-- The client can read only its own request metadata.
-- The client may create a pending request only; it cannot update/delete or approve it.
revoke all on table public.identity_verification_requests from anon, authenticated;
grant select on table public.identity_verification_requests to authenticated;
grant insert (user_id, method)
  on table public.identity_verification_requests to authenticated;

drop policy if exists identity_verification_select_own
  on public.identity_verification_requests;
create policy identity_verification_select_own
  on public.identity_verification_requests
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists identity_verification_insert_pending_own
  on public.identity_verification_requests;
create policy identity_verification_insert_pending_own
  on public.identity_verification_requests
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and status = 'pending_review'
    and assurance_level = 'none'
    and reviewer_actor_id is null
    and provider_reference is null
    and reason_code is null
    and reviewed_at is null
  );

-- No UPDATE/DELETE grant or policy for authenticated users.
-- Trusted server-side review code may manage records using the server-only service role.
-- Never expose the service-role key to Flutter or a browser client.
grant all on table public.identity_verification_requests to service_role;

-- Trusted review/provider integration must be implemented server-side before
-- status transitions can be used as authorization evidence. Never trust client state.
