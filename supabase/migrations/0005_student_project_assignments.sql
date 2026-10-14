-- Project assignment derived from the server-owned learning plan.
-- The server chooses the canonical project and task list; the student can only
-- read the current assignment and update progress through the existing route.

create table if not exists public.student_project_assignments (
  student_id text primary key,
  assignment jsonb not null check (
    jsonb_typeof(assignment) = 'object'
    and jsonb_typeof(assignment->'tasks') = 'array'
    and jsonb_typeof(assignment->'project') = 'object'
  ),
  source_plan_assessment_id text not null,
  updated_at timestamptz not null default now()
);

create index if not exists idx_student_project_assignments_updated
  on public.student_project_assignments (updated_at desc);

alter table public.student_project_assignments enable row level security;

grant select on public.student_project_assignments to authenticated;
grant select, insert, update on public.student_project_assignments to service_role;

drop policy if exists student_project_assignments_owner_select
  on public.student_project_assignments;
create policy student_project_assignments_owner_select
  on public.student_project_assignments
  for select
  to authenticated
  using (student_id = (select auth.uid())::text);
