-- Derived capability verification for the student's assigned project.
-- The result is auditable: it stores the source project and a JSON report
-- explaining covered tasks, evidence counts, and missing requirements.

create table if not exists public.student_capability_verifications (
  student_id text primary key,
  project_id text not null,
  verification jsonb not null check (
    jsonb_typeof(verification) = 'object'
    and verification ? 'capabilities'
    and verification ? 'audit'
  ),
  updated_at timestamptz not null default now()
);

create index if not exists idx_student_capability_verifications_updated
  on public.student_capability_verifications (updated_at desc);

alter table public.student_capability_verifications enable row level security;

grant select on public.student_capability_verifications to authenticated;
grant select, insert, update on public.student_capability_verifications to service_role;

drop policy if exists student_capability_verifications_owner_select
  on public.student_capability_verifications;
create policy student_capability_verifications_owner_select
  on public.student_capability_verifications
  for select
  to authenticated
  using (student_id = (select auth.uid())::text);
