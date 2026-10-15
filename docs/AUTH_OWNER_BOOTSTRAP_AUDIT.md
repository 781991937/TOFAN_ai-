# Auth & First-Owner Bootstrap Audit

**Date:** 2026-10-15  
**Repository:** `781991937/TOFAN_ai-`  
**Base branch:** `main`  
**Audit branch:** `audit/auth-owner-bootstrap-20261015`  
**Scope:** Static repository inspection only. No live Auth flow, database migration, Flutter test, or deployment was executed as part of this audit.

## Findings

### 1. Supabase initialization exists, but the app is not gated by authentication

- `lib/main.dart` initializes Supabase only when `SupabaseConfig.isConfigured` is true.
- The app's home remains `MainNavigation()`; the inspected navigation does not route unauthenticated users to a login/sign-up screen.
- `lib/config/supabase_config.dart` reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` at build time.

**Status:** Supabase client bootstrap is present; end-to-end app authentication UX is not demonstrated by the inspected entry/navigation code.

### 2. The existing auth adapter only implements password sign-in, current-session lookup, and sign-out

File: `lib/data/auth/supabase_authentication_gateway.dart`

- Sign-in uses Supabase `signInWithPassword`.
- Identity uses the Supabase Auth user UUID, rather than treating email as the actor identifier.
- Role lookup reads `user.appMetadata['role']`, which is server-managed metadata; untrusted user-editable metadata must not be used for authorization.
- No `signUp` or password-recovery operation was found in the searched repository results.
- The gateway packs email and password into one newline-delimited `credential` string. A future UI/API should replace this awkward contract with typed email/password parameters rather than storing or logging a combined credential string.

**Status:** Partial Auth adapter; registration and password recovery are not evidenced.

### 3. Owner checks are client-side configuration, not a complete trusted owner bootstrap

Files: `lib/config/supabase_config.dart`, `lib/providers/security_provider.dart`, `lib/domain/security/owner_authority.dart`

- `TOFAN_OWNER_ACTOR_ID` is read from Flutter build-time environment.
- `OwnerAuthority` compares the supplied actor ID with that configured value. If unset, it denies owner status.
- This is a local application guard, not a server-side grant/revocation mechanism. Build-time configuration shipped in a client must not be treated as an authoritative security boundary.
- The repository inspection did not find a trusted first-owner provisioning endpoint or a deployed Edge Function that atomically claims the first owner.
- A user's email address alone must not grant ownership. The trusted flow must first establish a verified Auth user ID, then provision owner authority through a server-controlled process and prevent later self-grants.

**Status:** Local owner guard exists; trusted first-owner provisioning is not evidenced.

### 4. There is no sign-in gate visible at the application root

File: `lib/main.dart`

The root widget always launches `MainNavigation`. No root-level auth-state gate was found in the inspected files. This means the existence of an auth gateway does not establish that the app's screens require an authenticated session.

**Status:** Integration gap to address after confirming the desired guest-access policy.

### 5. Migration source-of-truth requires reconciliation before adding more SQL files

The repository contains numbered migration files under `supabase/migrations/` (currently inspected through `0010_assessment_attempts_fk_index.sql`). The live Supabase migration history reported during the prior database work uses timestamp-style versions and names such as `20261015172925 harden_user_data_table_grants` and `20261015172950 remove_unsafe_table_level_privileges`.

Do not blindly add new numbered migrations or reapply schema changes. First reconcile the repository migration files with the actual remote migration ledger and record the exact SQL already applied. The two permission hardening changes were applied directly to Supabase in the prior operation; this audit did not reapply them.

**Status:** Migration drift/reconciliation is a prerequisite to safely continuing schema changes.

## Implementation order

1. Reconcile remote migration history with the repository's canonical SQL files, without reapplying the already-executed GRANT/REVOKE changes.
2. Define a trusted first-owner bootstrap contract: verified Auth UUID, one-time claim, server-side authorization, atomicity, audit trail, and explicit failure when already claimed.
3. Implement the privileged provisioning operation in a server-only environment. Never expose a Supabase service-role/secret key in Flutter or repository source.
4. Add typed sign-up, sign-in, session-state, sign-out, and password-recovery flows to the existing app architecture; honor the project's configured email-confirmation policy.
5. Gate protected screens and operations on the authenticated session. Keep academic guest access only if explicitly intended.
6. Remove reliance on `TOFAN_OWNER_ACTOR_ID` as a security boundary for privileged operations; keep server authorization authoritative.
7. Add unit and integration tests for registration, confirmation-required state, sign-in, recovery, logout, owner one-time claim, duplicate claim rejection, ordinary-user denial, and cross-user access.
8. Test against a non-production Supabase environment with two distinct users before production rollout.

## Evidence and limitations

This document is a static audit based on the inspected source files and search results. It does not claim that the app was built, tests were run, live Auth settings were read, an account was created, or owner privileges were provisioned. Those require separate executable checks and a controlled test environment.
