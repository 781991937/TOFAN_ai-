-- Server-derived learning gaps and plans.
-- Clients may read their own latest plan, but only the trusted grading API may write it.

create table if not exists public.student_learning_plans (
  student_id text primary key,
  plan jsonb not null check (
    jsonb_typeof(plan) = 'object'
    and jsonb_typeof(plan->'gaps') = 'object'
    and jsonb_typeof(plan->'priorityConceptIds') = 'array'
    and jsonb_typeof(plan->'prioritySkillIds') = 'array'
    and jsonb_typeof(plan->'prerequisiteCourseIds') = 'array'
  ),
  source_assessment_id text not null,
  updated_at timestamptz not null default now()
);

create index if not exists idx_student_learning_plans_updated
  on public.student_learning_plans (updated_at desc);

alter table public.student_learning_plans enable row level security;

grant select on public.student_learning_plans to authenticated;
grant select, insert, update on public.student_learning_plans to service_role;

drop policy if exists student_learning_plans_owner_select
  on public.student_learning_plans;
create policy student_learning_plans_owner_select
  on public.student_learning_plans
  for select
  to authenticated
  using (student_id = (select auth.uid())::text);
-- Deliberately no authenticated write policy: plans are derived by server grading.
