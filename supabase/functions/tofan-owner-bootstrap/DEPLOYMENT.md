# TOFAN Owner Bootstrap — Deployment Gate

## Current status

- This endpoint is not deployed by this document or by CI.
- The database migration is not applied to production.
- The bootstrap state defaults to `armed = false`.
- Do not merge or deploy until the isolated Supabase integration checks pass.

## Required server-side configuration

Set these only in the target Supabase project's Edge Function secrets/environment:

- `TOFAN_OWNER_BOOTSTRAP_SECRET`: a cryptographically random secret with at least 32 characters. Prefer 32 random bytes encoded as hex or base64url; do not use a human-created phrase.
- `TOFAN_OWNER_BOOTSTRAP_USER_ID`: the exact UUID of the intended, verified Supabase Auth user.
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` or `SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` or `SUPABASE_SECRET_KEY`

Never place the bootstrap secret or service-role/secret key in Flutter, client-side environment files, GitHub source, issue comments, logs, or chat. Do not create GitHub Actions secrets for these values unless a separately approved deployment pipeline requires them.

## Mandatory pre-deployment checks

1. Use a separate Supabase project or an isolated development branch; never trial the migration on production.
2. Confirm the intended user's Auth UUID through the authenticated Supabase dashboard. Do not infer it from email alone.
3. Run the migration and test: initially disarmed state; denied access for `anon` and `authenticated`; wrong user denied; wrong secret denied; first correct claim succeeds; replay and second user denied; exactly one registry row and one success audit record.
4. Run Supabase security advisors and inspect grants on `public.consume_tofan_owner_bootstrap(uuid)`.
5. Confirm the Edge Function deployment has JWT verification enabled. This repository explicitly sets `verify_jwt = true`; the function also validates the bearer token using Auth.
6. Confirm no production migration, function deployment, secret configuration, or owner assignment occurs during testing.

## Separate approval required

Do not arm the bootstrap state, deploy the function to production, apply the migration to production, assign the owner, or merge the PR until the project owner explicitly approves those actions after reviewing the staging evidence.
