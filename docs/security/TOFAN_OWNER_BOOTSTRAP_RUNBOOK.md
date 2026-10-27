# TOFAN AI — owner bootstrap deployment gate

## Status
Draft implementation for review only. No production migration or Edge Function has been applied by this change. The bootstrap database row is created disarmed; no owner is assigned automatically.

## Security model
- A caller must have a valid Supabase Auth session, the out-of-band bootstrap secret, and the exact Auth user ID configured by the deployment operator.
- The secret is server configuration (`TOFAN_OWNER_BOOTSTRAP_SECRET`), never a Flutter build-time value or repository secret.
- Set `TOFAN_OWNER_BOOTSTRAP_USER_ID` as a server-side Edge Function secret/config value to the exact, independently verified UUID of the intended Supabase Auth user. The endpoint fails closed if this value is missing and rejects every other user before calling the database RPC.
- The database performs a row-locked, one-time consume operation. A unique owner row and a consumed state prevent replays and concurrent first-owner claims.
- Owner records and audit data live in the non-exposed private schema. Only the server's service role can execute the narrowly scoped RPC.
- The endpoint does not collect biometric templates and does not claim to verify legal identity. Account authentication, deployer intent, legal identity verification, passkeys, and owner authorization are separate controls.

## Required steps before any production use
1. Review this PR and reconcile the migration against the live Supabase migration ledger and schema. Do not rename or replay existing numbered migrations.
2. Apply the migration only in an isolated Supabase branch/staging project; validate grants, function ownership, rollback behavior, and concurrent calls.
3. Deploy the Edge Function as `tofan-owner-bootstrap` with JWT verification enabled.
4. Set a cryptographically random secret of at least 32 characters as the server-side Edge Function secret `TOFAN_OWNER_BOOTSTRAP_SECRET`. Never put it in Flutter, GitHub source, client logs, or chat.
5. Independently verify the intended owner's Supabase Auth account UUID. Configure that exact UUID as `TOFAN_OWNER_BOOTSTRAP_USER_ID` in server-side function configuration. Treat it as an identity allowlist, not as a secret; never accept the ID from the request body or client.
6. Only after staging validation and a separate approval, arm the single row from the Supabase SQL editor:
   ```sql
   update private.tofan_owner_bootstrap_state
      set armed = true
    where singleton = true
      and consumed_at is null
      and not exists (select 1 from private.tofan_owner_registry);
   ```
   Confirm exactly one row was updated. If not, stop and investigate.
7. Have only the intended account call the function once using its active Auth access token and the secret. Confirm one owner row, one consumed state, and an audit record. Do not expose the secret in app telemetry.
8. Immediately remove/rotate the bootstrap secret after successful consumption. Test replay, wrong secret, missing JWT, concurrent requests, and already-owned state.
9. Only after review, add owner-authorized operations that query the server-owned registry. Never re-enable `TOFAN_OWNER_ACTOR_ID` as authority.
10. Separately design a real identity review process and passkey/WebAuthn enrollment/recovery before describing legal identity or biometric verification as complete.

## Known implementation limits
- This slice implements only the one-time server-side bootstrap gate and an allowlist check for the intended Auth user.
- It does not implement identity-document OCR, liveness/face matching, a trusted identity provider, passkey enrollment, owner transfer/recovery, or integration into all existing owner-only app actions.
- Production deployment is intentionally not performed from this PR.
- Unit tests for helper functions do not replace isolated Supabase integration tests for SQL transactions, grants, Edge Function runtime behavior, replay, and concurrency.
