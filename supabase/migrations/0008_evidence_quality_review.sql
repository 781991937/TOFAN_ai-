-- Evidence quality gate. Submitted evidence is reviewed deterministically by the
-- API before it can contribute to capability verification.

alter table public.project_task_evidence
  add column if not exists content_fingerprint text,
  add column if not exists quality_status text not null default 'rejected',
  add column if not exists quality_score integer not null default 0,
  add column if not exists quality_flags jsonb not null default '["legacy_unreviewed"]'::jsonb,
  add column if not exists reviewed_at timestamptz not null default now(),
  add column if not exists reviewer text not null default 'server-quality-gate';

alter table public.project_task_evidence
  drop constraint if exists project_task_evidence_quality_status_check;
alter table public.project_task_evidence
  add constraint project_task_evidence_quality_status_check
  check (quality_status in ('accepted', 'rejected'));

alter table public.project_task_evidence
  drop constraint if exists project_task_evidence_quality_score_check;
alter table public.project_task_evidence
  add constraint project_task_evidence_quality_score_check
  check (quality_score between 0 and 100);

create unique index if not exists uq_project_task_evidence_fingerprint
  on public.project_task_evidence (student_id, project_id, task_id, content_fingerprint)
  where content_fingerprint is not null;

create index if not exists idx_project_task_evidence_quality
  on public.project_task_evidence (student_id, project_id, quality_status);

-- Replace the earlier broad grant: quality status, score, flags, and reviewer
-- are server-owned and must not be forgeable by a client JWT.
revoke insert on public.project_task_evidence from authenticated;
grant insert on public.project_task_evidence to service_role;
