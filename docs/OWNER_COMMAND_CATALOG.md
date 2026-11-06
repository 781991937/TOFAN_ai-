# TOFAN Owner Command Catalog
**Document ID:** TOFAN-OWNER-COMMAND-CATALOG-001  
**Status:** APPROVED AS AN INVENTORY BASELINE; EXECUTABLE COMMANDS NOT YET APPROVED  
**Target branch:** `security/server-side-owner-authorization`  
**Related PR:** #22

## 1. Purpose and security boundary

This catalog separates (a) permissions represented in the current code from (b) commands that have a real server-side handler. A permission enum or Flutter-side grant is not an executable command and is not proof of server authorization.

The only owner identity accepted by a future server command handler is the verified Supabase Auth user ID returned by `GET /auth/v1/user`, matched against server-only `OWNER_USER_ID`. The role, when required, must come from trusted `app_metadata`; never from `user_metadata`, request JSON, query parameters, or Flutter state.

## 2. Canonical permission vocabulary found in the repository

The current code defines these permission classes:

| Permission | Intended meaning | Current executable owner command |
|---|---|---|
| READ | Read an explicitly scoped resource | None identified |
| SEARCH | Search an explicitly scoped resource | None identified |
| WRITE | Mutate an explicitly scoped resource | None identified |
| EXPORT | Export an explicitly scoped resource | None identified |
| ADMINISTER | Change administrative configuration | None identified |
| EXECUTE | Invoke an explicitly registered tool | None identified |

Sources: `lib/security/tofan_owner_command_authority.dart`, `lib/domain/execution/execution_models.dart`, and stage 14 in `docs/ROADMAP.md`.

These are permission classes, not approval to expose generic endpoints that accept arbitrary `permission`, `action`, or `resourceScope` values.

## 3. Resource scopes found in the current code

The only concrete owner-grant resource namespace found is:

`academic_library/{domainId}`

The current canonical domain IDs are:

- `core-computing`
- `ai-data`
- `systems-networking`
- `software-engineering`
- `interactive-computing`
- `security`
- `society-profession`

Source: `lib/security/library_authorization_gateway.dart` and `lib/data/academic/academic_library_security_catalog.dart`.

No wildcard scope is approved for a server API. The existing client-side grant model supports wildcard patterns, but that does not authorize their use by a server command executor.

## 4. Operation inventory and disposition

| Candidate capability | Existing evidence | Server-side disposition |
|---|---|---|
| Academic library READ | Library security policy and academic catalog GET routes exist | Existing catalog GET routes are authenticated catalog reads, not owner-only commands. No separate owner command endpoint is approved. |
| Academic library SEARCH | Permission enum and library authorization gateway exist | No dedicated server search handler was identified. Do not create one without a concrete search contract. |
| Academic library WRITE | Permission enum and library policy exist | No canonical write handler or persistence contract was identified. BLOCKED. |
| Academic library EXPORT | Permission enum and library policy exist | No export format, data boundary, or handler was identified. BLOCKED. |
| Academic library ADMINISTER | Permission enum and library policy exist | No administrative operation list or handler was identified. BLOCKED. |
| Tool EXECUTE | Roadmap stage 13 describes tool contracts; stage 14 describes owner authorization flow | No owner-connected server tool registry/executor was identified in the reviewed API. BLOCKED. |

### Explicitly excluded from owner commands

- Student self-service routes under `/v1/students/me`, learning, assessments, and project progress. These use the authenticated student's identity and RLS ownership boundary.
- Reviewer routes `GET /v1/reviews/evidence` and `POST /v1/projects/{projectId}/tasks/{taskId}/evidence/{evidenceId}/review`. These currently require reviewer/teacher/admin roles from verified `app_metadata`; they are reviewer workflow operations, not owner commands. Their authorization must remain separate unless an approved product requirement explicitly changes the reviewer model.
- `GET /health` and read-only public academic catalog content are not owner commands.

## 5. Required command contract before a route can be implemented

Every future command must have a fixed server-side registry entry containing:

1. Stable command ID (not supplied as authority by the caller).
2. Exact HTTP method and route.
3. Exact handler/tool implementation.
4. One permission from the vocabulary above.
5. One exact resource scope or a server-defined finite set of scopes.
6. Input schema and output schema.
7. Risk classification and whether explicit owner approval is required.
8. Maximum grant lifetime and replay/idempotency behavior.
9. Audit event fields and secret-redaction rules.
10. Tests proving unauthorized requests never invoke the handler.

The server must not accept a caller-defined handler, action, tool name, permission, owner identity, role, or arbitrary resource scope.

## 6. Required authorization sequence

The implementation must follow the roadmap's stage 14 sequence:

`OWNER → Authentication → Authorization → Scoped Grant → ABQARI → Policy Guard → Tool → Resource → Audit`

Minimum requirements:

- Verify the bearer token with Supabase Auth.
- Match the verified user ID to server-only `OWNER_USER_ID`.
- Reject if owner configuration is missing or malformed (503).
- Reject any non-owner (403).
- Resolve command ID through a fixed server allowlist.
- Derive permission and resource scope from the registry, not request JSON.
- Enforce expiry, no self-grant, least privilege, and explicit approval for sensitive operations.
- Enforce the policy guard immediately before handler invocation.
- Record an audit event without access tokens, API keys, or secret payloads.
- Deny unknown command IDs, scopes, permissions, and actions by default.

## 7. Implementation decision

**Do not add generic owner command routes yet.** The repository currently contains permission models and client-side authorization abstractions, but the reviewed backend does not contain the corresponding owner command handlers or concrete operation contracts. Adding routes now would create an authorization façade with no canonical action, or worse, an arbitrary command execution surface.

The safe next implementation unit is to select and specify one real command at a time (command ID, handler, exact resource, input/output, risk, approval, and audit). Once its implementation exists, add its fixed server route and end-to-end authorization tests in the same change.

## 8. Evidence and limitations

Reviewed on the target branch:

- `lib/security/tofan_owner_command_authority.dart`
- `lib/security/library_authorization_gateway.dart`
- `lib/backend/api/owner_authorization.dart`
- `lib/backend/api/tofan_api_server.dart`
- `bin/tofan_api_server.dart`
- `lib/backend/api/supabase_rest_gateway.dart`
- `lib/data/academic/academic_library_security.dart`
- `lib/data/academic/academic_library_security_catalog.dart`
- `lib/domain/security/oc_auth_models.dart`
- `lib/domain/security/owner_authority.dart`
- `lib/domain/execution/execution_models.dart`
- `docs/ROADMAP.md`
- `docs/BACKEND_API_IMPLEMENTATION.md`

This is a source-code inventory, not a production security certification. No production resources were accessed or changed. No staging/live Supabase authorization test is claimed.
