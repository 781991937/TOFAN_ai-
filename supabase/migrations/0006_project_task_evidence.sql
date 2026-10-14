-- Evidence submitted for an assigned canonical project task.
-- The API validates task membership against the server-owned assignment before
-- inserting a row; RLS additionally binds every row to auth.uid().

create table if not exists public.project_task_evidence (
  evidence_id uuid primary key default gen_random_uuid(),
  student_id text not null,
  project_id text not null,
  task_id text not null,
  evidence jsonb not null check (
    jsonb_typeof(evidence) = 'object'
    and evidence->>'type' in ('text', 'url', 'test_result', 'artifact')
    and length(trim(evidence->>'title')) between 1 and 160
    and length(trim(evidence->>'description')) between 1 and 4000
  ),
  submitted_at timestamptz not null default now()
);

create index if not exists idx_project_task_evidence_owner_task
  on public.project_task_evidence (student_id, project_id, task_id, submitted_at desc);

alter table public.project_task_evidence enable row level security;

grant select, insert on public.project_task_evidence to authenticated;

drop policy if exists project_task_evidence_owner_select
  on public.project_task_evidence;
create policy project_task_evidence_owner_select
  on public.project_task_evidence
  for select
  to authenticated
  using (student_id = (select auth.uid())::text);

drop policy if exists project_task_evidence_owner_insert
  on public.project_task_evidence;
create policy project_task_evidence_owner_insert
  on public.project_task_evidence
  for insert
  to authenticated
  with check (student_id = (select auth.uid())::text);
