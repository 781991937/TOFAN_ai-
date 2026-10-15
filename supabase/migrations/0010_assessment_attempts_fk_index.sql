-- Cover the self-referencing foreign key used when linking an assessment
-- attempt to the previous attempt. This keeps deletes and joins predictable.
create index if not exists idx_assessment_attempts_previous_attempt
  on public.assessment_attempts (previous_attempt_id);
