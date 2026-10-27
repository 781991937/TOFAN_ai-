# TOFAN AI — Owner Bootstrap Security Test Matrix

Status: pre-production validation plan. No production migration, function deployment, secret configuration, bootstrap arming, or owner assignment is authorized by this document.

## Unit tests included in this change

Run from the Supabase CLI/Deno environment:

```sh
deno test supabase/functions/tofan-owner-bootstrap/security_test.ts
```

The tests cover:
- bootstrap secret minimum length boundary (31 rejected, 32 accepted);
- valid and invalid Authorization Bearer header parsing;
- malformed request body rejection;
- exact secret match, wrong secret rejection, and unequal secret rejection;
- allowlist matching for the exact operator-approved Auth user ID;
- rejection of a different user ID and fail-closed behavior when the expected ID is missing.

Latest observed CI run for commit `590da8b62afbdaa048909bf7ab24717fa2218db5`: **success** — the Deno test step ran with type checking. This result covers the helper unit tests only, not database/runtime integration.

## Required integration tests before staging approval

These cases must be run against an isolated Supabase staging project with disposable test users and a fresh, unarmed bootstrap state. Do not use production secrets or production owner tables.

| Case | Setup / request | Required outcome | Database assertion |
|---|---|---|---|
| Missing JWT | POST without Authorization | 401 | No owner row; state remains unconsumed |
| Invalid/expired JWT | POST with invalid bearer token | 401 | No owner row; state remains unconsumed |
| Missing server config | Omit one required server environment value, including expected owner ID | 503 | No owner row |
| Weak configured secret | Configure fewer than 32 characters | 503 | No owner row |
| Missing/malformed body | Invalid JSON or no string bootstrapSecret | 400 | No owner row |
| Wrong secret | Valid JWT, incorrect secret | 403 | No owner row; state remains unconsumed |
| Wrong authenticated user | Valid JWT for a different user, even with correct secret | 403 before RPC | No owner row; state remains unconsumed |
| Missing expected owner ID | Omit `TOFAN_OWNER_BOOTSTRAP_USER_ID` | 503 before RPC | No owner row |
| Disarmed bootstrap | Approved user, valid JWT and correct secret, state armed=false | 409 | No owner row; state remains unconsumed |
| Successful one-time claim | Approved test user, valid JWT/secret, armed=true | 200 once | Exactly one registry row, consumed state, audit row |
| Replay | Repeat successful request | 409 | Still exactly one owner row; no second consumption |
| Concurrent claim | Send simultaneous valid requests for two test users; configure expected ID to one of them | At most one 200 and non-allowlisted user gets 403 | Exactly one owner row and one consumed state |
| Existing owner | Seed one owner in staging, then call endpoint | 409 | Existing owner unchanged |
| Secret rotation | Rotate secret after successful claim | Old secret rejected | Owner state unchanged |
| Client authorization | Attempt owner-only app action without server-backed authorization | Denied | No privileged write |

## Acceptance gates

1. Deno helper unit tests pass in CI with type checking (latest observed run linked from PR #21).
2. Run the integration matrix in staging; preserve redacted logs and database assertions.
3. Confirm the Edge Function is deployed with JWT verification enabled and secrets stored only in server-side function configuration.
4. Independently verify the intended Auth user and configure its exact UUID as `TOFAN_OWNER_BOOTSTRAP_USER_ID` before manually arming the one-time row.
5. Confirm every owner-only operation consults a server-owned authorization source; this bootstrap endpoint alone does not satisfy that requirement.
6. Review SQL grants, function owner/search_path, RLS, rollback behavior, and concurrent-claim behavior.
7. Rotate/remove the bootstrap secret immediately after a successful claim.

Do not mark production-ready based only on helper unit tests. They do not simulate Supabase Auth, the Edge Function runtime, database transactions, replay, or concurrency.
