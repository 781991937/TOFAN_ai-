# TOFAN Owner Command Catalog

**Document ID:** TOFAN-OWNER-COMMAND-CATALOG-001  
**Status:** ONE FIXED READ-ONLY COMMAND IMPLEMENTED ON PR BRANCH; REVIEW PENDING  
**Target branch:** `security/server-side-owner-authorization`  
**Related PR:** #22

## 1. Security boundary

A permission enum or Flutter-side grant is not proof of server authorization. The only owner identity accepted by the server is the verified Supabase Auth user ID returned by `GET /auth/v1/user`, matched against server-only `OWNER_USER_ID`. The role must come from trusted `app_metadata.role`, never `user_metadata` or request data.

## 2. Permission vocabulary

| Permission | Meaning | Executable owner command |
|---|---|---|
| READ | Read an explicitly scoped resource | None |
| SEARCH | Search an explicitly scoped resource | `academic_library.search` (read-only) |
| WRITE | Mutate an explicitly scoped resource | None |
| EXPORT | Export an explicitly scoped resource | None |
| ADMINISTER | Change administrative configuration | None |
| EXECUTE | Invoke an explicitly registered tool | None |

## 3. Implemented fixed command

| Field | Value |
|---|---|
| Command ID | `academic_library.search` |
| Method / route | `POST /v1/owner/commands/academic-library-search` |
| Handler | `AcademicKnowledgeEngine.searchInDomain` |
| Scope | One exact domain ID from `AcademicLibrarySecurityCatalog` |
| Grant | Server-created, single-use, 30-second |
| Mutation | None |
| Max results | 20 |

Canonical domain IDs:
- `core-computing`
- `ai-data`
- `systems-networking`
- `software-engineering`
- `interactive-computing`
- `security`
- `society-profession`

The search handler excludes items whose knowledge-area IDs do not map to the requested domain, before ranking and truncation. No wildcard scope is accepted.

## 4. Explicitly excluded from owner commands

- Student self-service routes under `/v1/students/me`, learning, assessments, and project progress. These continue to use the authenticated student's identity and existing RLS ownership boundary.
- Reviewer routes for evidence queues and evidence review. These remain reviewer workflow operations, separate from owner commands.
- Health and read-only academic catalog routes.

## 5. Not approved

No server-side owner command currently exists for WRITE, EXPORT, ADMINISTER, or generic tool EXECUTE. Do not expose generic endpoints accepting arbitrary `permission`, `action`, `handler`, or `resourceScope` values.

## 6. Audit and release status

Allow/deny events are emitted as structured JSON. The default sink is stdout and is not durable retention without deployment-level forwarding to a retained, access-controlled log sink.

This is branch implementation evidence, not production security certification. New HTTP integration tests require fresh green CI and independent review. No live Supabase staging verification is claimed. No production resources were changed; PR #22 remains unmerged.
