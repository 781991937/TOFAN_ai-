# Staging Migration Run

**Date:** 2026-10-15 20:10 (+03:00)

## Target

- **Supabase project:** `TOFAN_ai-`
- **Project ID:** `akzwfvtgdioghvwviczh`
- **Region:** `us-east-1`
- **Final status:** `ACTIVE_HEALTHY`

## Deployment result

The staging database was restored from `INACTIVE`, then the persistence, API, learning-plan, project, evidence, quality, and human-review schema was applied and verified.

The Supabase migration history records these deployment bundles:

| Migration history name | Scope |
|---|---|
| `production_persistence_baseline` | Initial persistence tables and RLS enablement |
| `rls_policies_and_append_only_audit` | Existing ownership and audit policies |
| `backend_api_resources_v2` | Profiles, assessment attempts, and project progress |
| `learning_gaps_and_plans_v2` | Learning plans, project assignments, and task evidence |
| `capability_and_human_review_v2` | Capability verification, evidence quality, and human review columns |
| `assessment_attempts_fk_index` | Foreign-key performance index |

The repository migrations remain the canonical source under `supabase/migrations/`.

## Verified public tables

- `student_learning_state`
- `experience_memory`
- `audit_events`
- `student_profiles`
- `assessment_attempts`
- `student_project_progress`
- `student_learning_plans`
- `student_project_assignments`
- `project_task_evidence`
- `student_capability_verifications`

`project_task_evidence` was verified with the automated quality and human-review columns:

- `content_fingerprint`
- `quality_status`
- `quality_score`
- `quality_flags`
- `reviewed_at`
- `reviewer`
- `human_review_status`
- `semantic_score`
- `review_notes`
- `reviewer_id`
- `human_reviewed_at`

## Security and performance checks

- Supabase security advisors: no findings.
- The unindexed self-referencing foreign key warning was resolved by migration `0010_assessment_attempts_fk_index.sql`.
- Remaining performance advisor messages are informational unused-index notices on an empty staging database and should be reassessed after representative traffic.

## Limitations

- Staging contains schema only; no student or evidence data was seeded.
- Reviewer roles still need to be provisioned in Supabase Auth `app_metadata` before using the review queue.
