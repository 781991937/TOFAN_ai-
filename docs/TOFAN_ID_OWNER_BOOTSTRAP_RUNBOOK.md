# TOFAN ID — owner bootstrap deployment runbook

**Status: prepared for review; not deployed.** The current linked Supabase projects were previously reported as inactive. Do not run these steps against a production project until its identity, access, backups, and migration plan have been reviewed.

## What this flow does

- Authenticates the caller using Supabase Auth; the Edge Function derives the account ID from the validated access token, never from request JSON.
- Requires a high-entropy one-time bootstrap secret held only in Edge Function server secrets.
- Requires an already trusted/reviewed identity-verification record.
- Uses migration `0004_tofan_owner_bootstrap.sql` to atomically consume the one-time bootstrap and create exactly one owner assignment.
- Denies client direct access to owner-assignment and bootstrap-state tables and denies client execution of the bootstrap RPC.

A server-side WebAuthn step-up ceremony, a Flutter client screen, and a trusted manual-review Edge Function have been added. The Flutter client uses `passkeys` pinned to `2.21.1` and is not passwordless Supabase login; the flow has not been tested on real devices. Document upload/OCR, a reviewer UI, owner transfer/recovery, network-level rate limiting, and enforcement at every privileged operation boundary remain unfinished. A basic account-scoped challenge limit is present. The temporary step-up receipt is not consumed by any application operation. Do not describe the whole identity system as production-ready.

## Required setup

1. Confirm the target Supabase project is active and is the intended project. Back up the database and review all migrations `0001` through `0005` in order.
2. Deploy migrations only after explicit project-owner approval. For a controlled environment, use the Supabase CLI's normal migration workflow; do not paste SQL into an unrelated project.
3. Generate a secret on a trusted operator machine, for example:

   ```sh
   openssl rand -base64 48
   ```

   Keep the output in a password manager or secure deployment vault. Never commit it, put it in Flutter `--dart-define`, or send it to logs or chat.
4. Set the secret as a Supabase Edge Function secret and deploy the function using the authenticated Supabase CLI:

   ```sh
   supabase secrets set TOFAN_OWNER_BOOTSTRAP_SECRET='<generated-secret>' --project-ref '<verified-project-ref>'
   supabase functions deploy tofan-owner-bootstrap --project-ref '<verified-project-ref>'
   supabase functions deploy tofan-passkey-step-up --project-ref '<verified-project-ref>'
   supabase functions deploy tofan-identity-review --project-ref '<verified-project-ref>'
   ```

   Use the actual verified project ref; do not copy a ref from an old/inactive environment. Supabase provides the function's server-side `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` environment values. The service-role key must never be sent to the client.
5. Configure the WebAuthn Edge Function secrets `TOFAN_WEBAUTHN_RP_ID` and `TOFAN_WEBAUTHN_ORIGIN` for the real relying-party setup. The origin setting accepts a comma-separated list of exact allowed origins; never use wildcards or guessed values. The Android application ID currently in Gradle is `com.tofanai.tofan_ai`; publish the matching `/.well-known/assetlinks.json` for the real RP domain and confirm the signing certificate SHA-256 fingerprint. The repository currently has no iOS Runner configuration, so do not claim iOS support until the target exists and its Associated Domains entitlement plus `/.well-known/apple-app-site-association` are configured. The Flutter screen is now wired to call the Edge Function, but end-to-end use remains blocked until these real domain/platform values are configured and device-tested.
6. Grant `app_metadata.identity_reviewer = true` only to a specifically authorized reviewer using trusted Supabase admin tooling; never set this in user-editable `user_metadata`. The reviewer must inspect the document through a separately approved secure process. This app does not upload documents or check a government source, so the endpoint records a manual decision only and does not prove government-document authenticity.
7. The owner claim intentionally fails until the account has a valid `verified` row written by the trusted reviewer endpoint with the required assurance fields. Do not manually mark a record verified to bypass this guard.
8. Invoke the bootstrap function only from a freshly authenticated account and transmit the bootstrap secret over HTTPS. Treat the secret as consumed once an owner is assigned; rotate/remove the function secret immediately afterward. The database also enforces one-time use, so retries after success must fail.
9. Verify that one owner row exists, client roles cannot read or alter it, a second claim fails, and the audit trail contains no secret or identity-document contents.

## Operational safety

- If no owner assignment exists and the secret is absent, expired operationally, or incorrect, the system must remain ownerless and deny privileged actions.
- Recovery must require trusted operator intervention; never add a public “make me owner” fallback.
- Do not enable public launch until owner authorization is enforced server-side at each privileged operation boundary and passkey step-up/recovery flows have been implemented and tested.
- No live migration, secret installation, function deployment, or ownership claim was performed while preparing this document.


## Trusted manual review

- Set `app_metadata.identity_reviewer = true` only through trusted Supabase admin tooling for a specifically authorized reviewer account. Never authorize from user-editable `user_metadata`.
- The `tofan-identity-review` Edge Function allows only pending manual-review requests, blocks self-review, uses a compare-and-set update, and accepts only fixed reason codes.
- The reviewer must inspect documents using an approved secure process outside the app. The app currently does not upload documents or query a government identity authority; the record is a manual-review decision, not a cryptographic government-document authenticity proof.
