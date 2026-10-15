# Supabase migration reconciliation and security review — 2026-10-15

## Status and safety boundary

This is a read-only reconciliation record based on the live Supabase catalog/advisors and the current GitHub `main` files. No production DDL was executed in this review, no Edge Function was deployed, no migration was replayed, and no user/owner account was created or approved.

## Live migration ledger

The connected Supabase project `akzwfvtgdioghvwviczh` reports these eight applied versions:

| Remote version | Remote name |
|---|---|
| `20261002200001` | `production_persistence_baseline` |
| `20261002200009` | `rls_policies_and_append_only_audit` |
| `20261015170935` | `backend_api_resources_v2` |
| `20261015170949` | `learning_gaps_and_plans_v2` |
| `20261015170959` | `capability_and_human_review_v2` |
| `20261015171033` | `assessment_attempts_fk_index` |
| `20261015172925` | `harden_user_data_table_grants` |
| `20261015172950` | `remove_unsafe_table_level_privileges` |

The repository uses a different local filename/version scheme. Files confirmed on `main` include `0001_production_persistence_baseline.sql`, `0002_authenticated_owner_rls.sql`, `0003_backend_api_resources.sql`, `0004_learning_gaps_and_plans.sql`, `0005_student_project_assignments.sql`, `0006_project_task_evidence.sql`, `0008_evidence_quality_review.sql`, and `0010_assessment_attempts_fk_index.sql`.

No exact matching repository migration file was found for the two remote grant-hardening names. The six schema bundles and the two grant-hardening entries have not yet been mapped one-to-one by content/hash. Therefore, **do not run `supabase db push`, replay local migrations, or repair migration history until an explicit mapping is reviewed**.

## Live schema and permission observations

- Ten public application tables were returned by the catalog query; RLS is enabled on all ten. `FORCE ROW LEVEL SECURITY` is false on these tables; this is recorded, not treated by itself as a vulnerability.
- Security Advisor returned no findings during this snapshot. This is not proof that application-level authorization is complete.
- Performance Advisor returned 16 informational `unused_index` findings. Do not drop these indexes based only on an empty/low-traffic staging snapshot.
- `project_task_evidence`: `authenticated` currently has `SELECT` only; `service_role` has server-side write privileges. This matches the intent in `0008_evidence_quality_review.sql` to prevent clients from forging quality/reviewer columns.
- `student_profiles`: the live catalog reports `DELETE` for `authenticated`, while `0003_backend_api_resources.sql` grants only `SELECT, INSERT, UPDATE`. This is a confirmed privilege drift that should be removed in a reviewed migration after the history mapping is resolved.
- `audit_events`: authenticated users can insert and read their own rows; an append-only trigger blocks updates/deletes. Since clients can author these rows, they must not be treated as authoritative evidence of privileged server actions. Server-generated security audit events should be separated from client telemetry.
- `student_learning_state`: users can update their own JSON payload. Treat this payload as user-controlled state; any role, verification, or capability claim inside it must be recomputed or independently validated server-side.
- The catalog showed the `rls_auto_enable` event-trigger function as `SECURITY DEFINER` with `search_path=pg_catalog` and execute ACL limited to `postgres`/ `service_role`; the trigger function body was inspected. No change was made.

## Owner bootstrap is not installed

Live checks returned:
- `auth.users` count: 0
- `public.tofan_owner_assignment`: absent
- `public.identity_verification_requests`: absent
- `private.tofan_owner_bootstrap_state`: absent
- deployed Supabase Edge Functions: none

PR #2 already contains a proposed identity/owner/passkey design, but its proposed migrations `0003_identity_verification_requests.sql`, `0004_tofan_owner_bootstrap.sql`, and `0005_tofan_passkey_step_up.sql` collide by number with the existing `main` migrations `0003_backend_api_resources.sql`, `0004_learning_gaps_and_plans.sql`, and `0005_student_project_assignments.sql`. PR #2 must not be merged or deployed until these migration names are reconciled and its server-side authorization boundaries are independently reviewed. Its runbook also states that owner enforcement at every privileged operation boundary and real-device passkey testing remain unfinished.

## PR #15 validation update

For commit `11474f2170f780356e9270b70fd47a57394af2b1`, GitHub Actions reported success for:
- Flutter quality run `38780670503`: dependency install, roadmap-baseline check, Analyze, and Test passed.
- Academic Library Approval Gate run `38780670399`: approval tests, integration tests, and full test suite passed.

These CI results validate that commit's configured workflows; they do not validate live Supabase Auth, an owner bootstrap, or a production deployment. PR #15 remains a draft and is not merged.

## Required order of remediation

1. Build and review a file-by-file mapping from local migration SQL to all eight remote migration records; record hashes and identify any remote-only DDL.
2. Select one canonical migration-version strategy and reconcile the repository/remote ledger without replaying existing schema changes.
3. Add a migration to revoke the unexpected `DELETE` privilege on `student_profiles`, then verify effective grants and RLS in an isolated database before any production change.
4. Define server-authored audit events separately from client-authored activity records; do not treat client inserts as trusted security evidence.
5. Keep user-controlled learning JSON non-authoritative for verification/capability decisions.
6. Review and repair PR #2's migration collisions; validate owner bootstrap atomicity, reviewer authorization, replay resistance, and enforcement at every privileged endpoint.
7. Run CI and isolated database tests. Deploy functions, apply production migrations, create an owner, or grant owner authority only after separate explicit approval.

## Not done in this review

No database privileges were changed, no migration history was repaired, no Edge Function was deployed, no passkey/identity provider was configured, no live Auth flow was exercised, and no owner account or owner assignment was created.
