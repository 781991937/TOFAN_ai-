# Owner authorization remediation — stage 1

Status: **implemented on an isolated branch; not merged or deployed**.

## Security decision

Owner privileges must be derived exclusively from the server-verified Supabase Auth user response:

- identity: the verified Auth `id`;
- role: `app_metadata.role`, returned by `GET /auth/v1/user`;
- configured owner: a server-only UUID supplied through deployment configuration;
- authorization: both the verified UUID and exact `owner` role must match.

Never authorize from Flutter-only grants, request-body identity fields, `user_metadata`, client-supplied role values, or a user-editable JWT metadata claim.

## Change in this branch

`lib/backend/api/owner_authorization.dart` introduces a fail-closed server policy. It rejects malformed/missing owner configuration with HTTP 503 and rejects non-owner/mismatched identities with HTTP 403. It is deliberately separate from the client-side `TofanOwnerCommandAuthority`.

Tests cover the configured owner, wrong UUID, wrong role, case/whitespace normalization, and missing/malformed configuration.

## Important boundary

The current REST server has no owner-command routes. This patch does **not** invent or expose privileged commands. Before any owner operation is added, its route must call `OwnerAuthorizationPolicy.requireOwner(principal)` before executing the operation, and must independently validate the requested command against a server-side allowlist and resource scope.

The deployment must configure the owner UUID only after verifying the intended Supabase Auth account. Do not copy the service-role key or owner UUID into Flutter, source control, or logs.

## Not done

- No production database, RLS policy, migration, Auth user, or Supabase setting was changed.
- No service was deployed.
- No merge to `main` was performed.
- Tests have not yet been executed in this environment; passing status must not be inferred from adding test files.
- A separate live staging test is still required for Auth metadata provenance and cross-user isolation.
