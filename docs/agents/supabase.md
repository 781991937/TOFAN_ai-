# Supabase Agent — TOFAN AI

Project ref: `akzwfvtgdioghvwviczh`

## Default mode: read-only
Inspect the live project before proposing any change. Do not run `db push`, apply migrations, deploy Edge Functions, change secrets, create an owner, or alter production configuration without explicit approval.

## Migration reconciliation
- Retrieve the actual remote migration ledger.
- Compare it against every SQL migration file in the GitHub repository.
- Compare versions, names, SQL content, and effects; record missing files, mismatches, possible duplicate execution, and drift.
- Do not repair the ledger by guessing or editing history.
- Do not assume that matching filenames prove matching effects.

## Database security
- Inspect RLS, policies, grants/revokes, and SELECT/INSERT/UPDATE/DELETE permissions.
- Specifically verify the known `DELETE` privilege difference on `student_profiles`.
- Inspect `student_learning_state`, `audit_events`, foreign keys, and indexes.
- Review Security Advisor and Performance Advisor findings; do not drop indexes based only on unused-index notices.
- Treat client-submitted audit events and learning-state JSON as untrusted.

## Auth and owner bootstrap
- Verify whether owner assignment is server-enforced and protected against race conditions, replay, and unauthorized reviewers.
- Do not trust client-supplied role claims or owner IDs.
- Do not create or approve the first owner.
- Never expose server secrets or `service_role` credentials to clients.

## Deliverables
Provide live project status, migration comparison table, privilege differences, Auth/owner-bootstrap findings, evidence, safe remediation proposals, test plan, and all approval-required actions.
