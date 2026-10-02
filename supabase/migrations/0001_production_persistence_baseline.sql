-- TOFAN AL-ABQARI production persistence baseline.
-- Apply through Supabase migrations. No client secrets are stored here.

create table if not exists public.student_learning_state (
  student_id text primary key,
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

create index if not exists idx_student_learning_updated
  on public.student_learning_state (updated_at desc);

create table if not exists public.experience_memory (
  id text primary key,
  actor_id text not null,
  task text not null,
  outcome text not null,
  observation text not null,
  learned_skill_ids jsonb not null default '[]'::jsonb,
  created_at timestamptz not null
);

create index if not exists idx_experience_actor
  on public.experience_memory (actor_id);

create index if not exists idx_experience_created
  on public.experience_memory (created_at desc);

create table if not exists public.audit_events (
  id text primary key,
  actor_id text not null,
  action text not null,
  resource_id text not null,
  outcome text not null,
  timestamp timestamptz not null,
  reason text not null
);

create index if not exists idx_audit_actor
  on public.audit_events (actor_id);

create index if not exists idx_audit_resource
  on public.audit_events (resource_id);

create index if not exists idx_audit_timestamp
  on public.audit_events (timestamp desc);

-- Row Level Security is enabled at the database boundary.
-- Policies must be added only after the application's authenticated
-- identity/role mapping is defined; deny-by-default is safer than
-- publishing an incorrect policy.
alter table public.student_learning_state enable row level security;
alter table public.experience_memory enable row level security;
alter table public.audit_events enable row level security;
