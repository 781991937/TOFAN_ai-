# Academic Library Search — Owner Command Contract

**Document ID:** TOFAN-ACADEMIC-LIBRARY-SEARCH-COMMAND-001  
**Status:** `CONTRACT PROPOSED; IMPLEMENTATION BLOCKED ON SERVER SECURITY PRIMITIVES`  
**Target branch:** `security/server-side-owner-authorization`  
**Related PR:** #22

## 1. Verified implementation evidence

The repository contains a real canonical search implementation:

- `lib/abqari/academic_knowledge_engine.dart`
- `AcademicKnowledgeEngine.search(String query)`
- Search traverses the canonical `AcademicCatalog` curriculum and shared foundation courses.
- It searches lesson titles, definitions, content, applications, key terms, learning outcomes, course/specialization context, and canonical knowledge-unit descriptions.
- It ranks matching `AbqariKnowledgeItem` records and currently returns at most 20.
- `AbqariKnowledgeItem` carries source identifiers, course/unit/lesson identifiers, knowledge-area/unit IDs, concepts, skills, applications, and learning outcomes.

This is a real retrieval engine, unlike a proposed route backed by placeholder data.

## 2. Security classification

This command is an owner-invoked ABQARI retrieval operation, not a replacement for ordinary student/tutor search and not a library content mutation.

The current engine searches across the whole canonical catalog. The approved server resource namespace is domain-specific:

`academic_library/{domainId}`

The seven canonical domain IDs are defined in `AcademicLibrarySecurityCatalog`. A global search must not silently use a wildcard scope. The implementation must accept one domain ID from the fixed catalog and filter matching records to that domain **before ranking/truncation**. Filtering the engine's already-truncated top-20 result would produce incomplete and potentially misleading results.

The existing client-side `OwnerCommandGrant` is not trusted server authorization and must not be reused as proof of a server grant.

## 3. Proposed fixed command registry entry

| Field | Fixed value |
|---|---|
| Command ID | `academic_library.search` |
| Method | `POST` |
| Route | `/v1/owner/commands/academic-library-search` |
| Handler | Server-owned adapter over `AcademicKnowledgeEngine` |
| Permission | `SEARCH` |
| Resource scope | `academic_library/{validated-domain-id}` |
| Owner identity | Verified Supabase Auth user ID equals server-only `OWNER_USER_ID` |
| Role | Verified `app_metadata.role == owner` |
| Approval | Explicit authenticated owner request to this fixed command |
| Maximum result count | 20 |
| Mutation | None; read-only retrieval |

No caller-provided command ID, permission, role, owner ID, handler, action, tool name, or arbitrary resource scope is accepted.

## 4. Proposed request contract

JSON object with exactly these fields:

- `domainId`: required string; must exactly match one of the seven canonical domain IDs.
- `query`: required trimmed string; 2–200 Unicode characters.
- `limit`: optional integer, default 20, range 1–20.

Reject unknown fields, missing fields, invalid domain IDs, empty/oversized queries, and invalid limits with HTTP 400. Do not echo raw query text into audit logs.

## 5. Proposed response contract

HTTP 200:

- `data.commandId`: `academic_library.search`
- `data.domainId`: validated domain ID
- `data.items`: up to the requested limit, each containing:
  - `id`, `title`, `sourcePath`
  - `definition`, `content`
  - `applications`, `learningOutcomes`, `terms`
  - `conceptIds`, `skillIds`
  - `knowledgeAreaIds`, `knowledgeUnitIds`
  - `courseId`, `unitId`, `lessonId`
  - `projectTitles`
- `data.total`: number of returned items (not a claim about all possible matches).

The handler must return only items whose knowledge-area IDs map to the requested domain. If an item has no recognized domain mapping, it is excluded.

## 6. Required server-side security sequence

1. Require a bearer token and verify it through Supabase Auth `/auth/v1/user`.
2. Require a valid server-only `OWNER_USER_ID`; missing/malformed configuration returns 503.
3. Require verified user ID equality and `app_metadata.role == owner`; otherwise return 403.
4. Validate the fixed route and exact request schema.
5. Resolve the domain against `AcademicLibrarySecurityCatalog`; derive scope on the server.
6. Issue/validate a short-lived, single-command, single-domain server-side grant (maximum 60 seconds); do not trust Flutter grant objects or caller-supplied grant fields.
7. Apply the policy guard immediately before invoking the search handler.
8. Emit a structured audit event containing command ID, verified owner user ID, domain ID, outcome, timestamp, and correlation ID. Never log bearer tokens, API keys, or raw query/content.
9. Return the scoped result.

Unknown command IDs and invalid scopes must fail closed.

## 7. Blocking prerequisites before route implementation

The reviewed backend does not yet provide all required security primitives:

- `OWNER_USER_ID` is not yet wired into `TofanApiServer` / `bin/tofan_api_server.dart`.
- The current `OwnerAuthorizationPolicy` verifies owner identity/role only; it does not issue or validate a scoped, expiring, single-use server grant.
- No server-side command registry/policy guard currently binds this command ID to its fixed permission and scope.
- No structured audit sink exists for owner command invocation.
- The search engine currently has no domain-filtered search API; its top-20 truncation occurs before a caller could safely filter by domain.

These are implementation blockers, not reasons to weaken the contract. Do not add the route until they are resolved.

## 8. Required tests

Before the route is considered implemented, add HTTP-level tests proving:

- Missing/invalid bearer token is rejected before handler invocation.
- Invalid Supabase identity response is rejected.
- Missing/malformed `OWNER_USER_ID` returns 503.
- Non-owner and wrong-owner identities return 403.
- Invalid/unknown domain is rejected.
- Invalid schema, query length, and limit are rejected.
- Cross-domain records never appear in results.
- Domain filtering occurs before result truncation.
- Expired, replayed, wrong-command, and wrong-domain grants are rejected.
- Unauthorized requests never invoke the search engine.
- Successful owner request returns only the documented response fields.
- Audit records contain no token, API key, or raw query.

## 9. Execution boundary

This document defines a proposed contract only. It does not claim that the endpoint, grant system, audit sink, or domain-filtered search has been implemented or tested. No production resource, Supabase project, database, or deployed service may be changed as part of this work. All implementation remains branch-only until separately reviewed.
