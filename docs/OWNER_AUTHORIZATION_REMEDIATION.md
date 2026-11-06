# Owner authorization remediation — server-side command stage

Status: **implemented on the isolated PR branch; current CI verification pending; not merged or deployed**.

## Security decision

Owner privileges are derived exclusively from the server-verified Supabase Auth user response:
- identity: verified Auth `id`;
- role: `app_metadata.role` returned by `GET /auth/v1/user`;
- configured owner: server-only UUID supplied through `OWNER_USER_ID`;
- authorization: both the verified UUID and exact `owner` role must match.

Never authorize from Flutter grants, request-body identity fields, `user_metadata`, client-supplied role values, or user-editable metadata.

## Implemented branch changes

- `OWNER_USER_ID` is read into `SupabaseApiConfig` from process environment.
- `OwnerAuthorizationPolicy` fails closed: missing/malformed configuration returns 503; wrong identity or role returns 403.
- `ServerOwnerCommandGate` defines the fixed `academic_library.search` command and issues 30-second, single-use, single-domain grants.
- `TofanApiGatewayServer` exposes the fixed owner command route, verifies the bearer token through Supabase Auth, validates the exact request schema, applies the owner policy, consumes the grant, and serializes canonical search results.
- The public API entrypoint starts the gateway. Existing API routes are forwarded to the existing `TofanApiServer`; ordinary student routes are not converted to owner-only routes.
- `AcademicKnowledgeEngine.searchInDomain` filters candidates by canonical knowledge-area mapping before ranking and result truncation.
- HTTP integration tests cover successful owner access, student denial despite `user_metadata.role=owner`, wrong owner identity, malformed Auth identity, missing/invalid bearer, missing owner configuration, invalid domain/schema/query/limit, audit redaction, domain scope, grant expiry, and replay rejection.

## Audit limitation

The default audit sink emits structured JSON to stdout. It is not durable retention without deployment-level forwarding to a retained, access-controlled log service. This branch does not create or configure that service.

## Not done

- Current CI for the new commits has not yet been verified; prior green runs predate this implementation.
- No live staging test against Supabase Auth has been performed.
- `OWNER_USER_ID` has not been configured in a deployment.
- No durable retained audit sink has been configured or verified.
- No production database, RLS policy, migration, Auth user, Supabase setting, or service deployment was changed.
- No merge to `main` was performed.

Do not mark the work approved until fresh CI, HTTP integration tests, and independent security review pass. A live staging verification is still required before deployment.
