# Academic Library Search — Owner Command Contract

**Document ID:** TOFAN-ACADEMIC-LIBRARY-SEARCH-COMMAND-001  
**Status:** `IMPLEMENTED ON BRANCH; CI AND INTEGRATION VERIFICATION PENDING`  
**Target branch:** `security/server-side-owner-authorization`  
**Related PR:** #22

## 1. Fixed command

| Field | Value |
|---|---|
| Command ID | `academic_library.search` |
| Method | `POST` |
| Route | `/v1/owner/commands/academic-library-search` |
| Handler | Server-side adapter over `AcademicKnowledgeEngine.searchInDomain` |
| Permission | `SEARCH` |
| Resource scope | `academic_library/{canonical-domain-id}` |
| Owner identity | Verified Supabase Auth user ID equals server-only `OWNER_USER_ID` |
| Role | Verified `app_metadata.role == owner` |
| Maximum result count | 20 |
| Mutation | None; read-only retrieval |

The API process entrypoint uses `TofanApiGatewayServer` as its public front door. It intercepts this one fixed owner route and forwards existing non-owner routes to the existing `TofanApiServer`. The ordinary student and academic catalog routes are not converted into owner-only routes.

## 2. Request and response contract

Request JSON accepts only:
- `domainId`: required exact ID from `AcademicLibrarySecurityCatalog.domains`.
- `query`: required trimmed text, 2–200 Unicode code points.
- `limit`: optional integer, default 20, range 1–20.

Unknown fields, missing fields, invalid scopes, invalid queries, and invalid limits are rejected. Caller-supplied command IDs, permissions, owner IDs, roles, and grant fields are not accepted.

HTTP 200 returns `data.commandId`, `data.domainId`, `data.items`, and `data.total`. Each item contains canonical lesson/source identifiers, content, definitions, applications, outcomes, terms, concepts, skills, knowledge areas/units, course/unit/lesson IDs, and project titles.

## 3. Security sequence

1. Require a bearer token.
2. Verify it through Supabase Auth `GET /auth/v1/user`.
3. Derive user ID from the verified Auth response and role only from `app_metadata.role`.
4. Require a valid server-only `OWNER_USER_ID`; absent or malformed configuration fails closed with 503.
5. Require both exact owner identity and `owner` role; otherwise return 403.
6. Validate the fixed request schema and resolve the domain against the canonical catalog.
7. Issue and immediately consume a server-created, single-use grant scoped to the fixed command and one domain. Grant lifetime is 30 seconds.
8. Filter all search candidates by the domain's knowledge-area IDs before ranking and truncating.
9. Emit structured allow/deny events without bearer tokens, API keys, or raw query text.

The search engine's ordinary global `search(String)` behavior remains available to existing consumers. The new `searchInDomain` API is additive and scoped.

## 4. Implementation files

- `lib/backend/api/tofan_api_gateway_server.dart`: public gateway, owner route, auth, schema validation, scoped grant, result serialization, and forwarding of existing API routes.
- `bin/tofan_api_server.dart`: starts the gateway as the API entrypoint.
- `lib/backend/api/api_models.dart`: reads server-only `OWNER_USER_ID` from process environment.
- `lib/backend/api/owner_authorization.dart`: fail-closed owner identity and role policy.
- `lib/backend/api/server_owner_command_gate.dart`: fixed command grant and authorization audit events.
- `lib/abqari/academic_knowledge_engine.dart`: domain filtering before ranking/truncation.
- `test/server_owner_command_http_test.dart`: HTTP integration and security boundary tests.

## 5. Audit limitation

The default audit sink writes structured JSON to process stdout. This is structured event emission, **not durable retained audit storage** by itself. Production deployment must route stdout to a retained, access-controlled log sink and verify retention before treating audit evidence as durable. Tests can inject an in-memory writer to verify redaction.

## 6. Verification still required

The new HTTP tests are committed on the branch, but must pass in a fresh GitHub Actions run. The existing successful workflow runs predate this implementation and do not verify it. No live Supabase staging test has been performed. The owner UUID has not been configured in any deployment.

## 7. Execution boundary

All changes remain branch-only. No production database, Supabase project, Auth user, RLS policy, deployment, or paid resource has been changed. PR #22 remains unmerged pending independent review and current CI evidence.
