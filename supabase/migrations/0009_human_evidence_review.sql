-- Human and semantic review gate for automatically accepted evidence.
-- Accepted-by-quality evidence is pending until an authorized reviewer records
-- a semantic decision and score.

alter table public.project_task_evidence
  add column if not exists human_review_status text not null default 'pending_review',
  add column if not exists semantic_score integer,
  add column if not exists review_notes text,
  add column if not exists reviewer_id text,
  add column if not exists human_reviewed_at timestamptz;

alter table public.project_task_evidence
  drop constraint if exists project_task_evidence_human_review_status_check;
alter table public.project_task_evidence
  add constraint project_task_evidence_human_review_status_check
  check (human_review_status in ('pending_review', 'approved', 'rejected'));

alter table public.project_task_evidence
  drop constraint if exists project_task_evidence_semantic_score_check;
alter table public.project_task_evidence
  add constraint project_task_evidence_semantic_score_check
  check (semantic_score is null or semantic_score between 0 and 100);

create index if not exists idx_project_task_evidence_human_review
  on public.project_task_evidence (project_id, human_review_status, submitted_at desc);
