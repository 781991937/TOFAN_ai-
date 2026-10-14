-- Backend API data resources. No seed or fabricated academic content is added.
-- Identity remains the verified Supabase Auth UUID stored as text, matching the
-- existing repositories and auth.uid()::text owner policies.

create table if not exists public.student_profiles (
  student_id text primary key,
  profile jsonb not null check (jsonb_typeof(profile) = 'object'),
  updated_at timestamptz not null default now()
);

create table if not exists public.assessment_attempts (
  attempt_id uuid primary key default gen_random_uuid(),
  student_id text not null,
  course_id text not null,
  lesson_id text not null,
  assessment_id text not null,
  attempt_number integer not null check (attempt_number > 0),
  score integer not null check (score >= 0),
  total integer not null check (total > 0 and score <= total),
  percentage numeric(5, 2) generated always as
    (round(score::numeric * 100 / total, 2)) stored,
  passed boolean generated always as
    (score::numeric * 100 >= total::numeric * 60) stored,
  wrong_question_ids jsonb not null default '[]'::jsonb
    check (jsonb_typeof(wrong_question_ids) = 'array'),
  previous_attempt_id uuid references public.assessment_attempts(attempt_id),
  completed_at timestamptz not null default now(),
  constraint assessment_attempt_owner_sequence_unique
    unique (student_id, assessment_id, attempt_number)
);

create index if not exists idx_assessment_attempts_owner_time
  on public.assessment_attempts (student_id, completed_at desc);

create index if not exists idx_assessment_attempts_owner_assessment
  on public.assessment_attempts (student_id, assessment_id, attempt_number desc);

create table if not exists public.student_project_progress (
  student_id text not null,
  project_id text not null,
  progress jsonb not null check (
    jsonb_typeof(progress) = 'object'
    and progress->>'status' in ('in_progress', 'submitted')
    and jsonb_typeof(progress->'completedTasks') = 'array'
    and jsonb_typeof(progress->'notes') = 'string'
  ),
  updated_at timestamptz not null default now(),
  primary key (student_id, project_id)
);

create index if not exists idx_student_project_progress_updated
  on public.student_project_progress (student_id, updated_at desc);

alter table public.student_profiles enable row level security;
alter table public.assessment_attempts enable row level security;
alter table public.student_project_progress enable row level security;

grant select, insert, update
  on public.student_profiles to authenticated;
grant select
  on public.assessment_attempts to authenticated;
grant select, insert, update, delete
  on public.student_project_progress to authenticated;
grant select, insert
  on public.assessment_attempts to service_role;

drop policy if exists student_profiles_owner_all
  on public.student_profiles;
create policy student_profiles_owner_all
  on public.student_profiles
  for all
  to authenticated
  using (student_id = (select auth.uid())::text)
  with check (student_id = (select auth.uid())::text);

drop policy if exists assessment_attempts_owner_select
  on public.assessment_attempts;
create policy assessment_attempts_owner_select
  on public.assessment_attempts
  for select
  to authenticated
  using (student_id = (select auth.uid())::text);
-- Deliberately no authenticated INSERT/UPDATE/DELETE policy: only the server's
-- grading endpoint may insert assessed outcomes using its server-only role.

drop policy if exists student_project_progress_owner_all
  on public.student_project_progress;
create policy student_project_progress_owner_all
  on public.student_project_progress
  for all
  to authenticated
  using (student_id = (select auth.uid())::text)
  with check (student_id = (select auth.uid())::text);
