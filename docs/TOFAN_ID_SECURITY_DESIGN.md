# TOFAN ID — Identity Verification and Owner Authorization Design

**Status:** Initial implementation slice in a draft PR. The domain metadata model, current-user request repository, provider registration, and proposed RLS migration exist on the feature branch. This is not a complete or production-ready identity-verification system.

## Goals
Integrate an identity-verification workflow into the existing TOFAN AI architecture without creating a parallel app or weakening current authorization. Identity verification, device authentication, and project-owner authorization are separate decisions.

## Security invariants
1. Supabase Auth user ID (`auth.uid()` / `currentUser.id`) is the canonical account identity. Email, display name, OCR output, client-provided flags, and a submitted document are not authentication proofs.
2. A verified identity does not automatically become the project owner. Owner status must be bound to an explicitly configured, trusted account identity and enforced server-side / by database policy.
3. The client must never be trusted to set ownerAuthenticated, a verification status, reviewer identity, or an administrative role. Owner-command grants must not be minted by Flutter code from caller-supplied booleans.
4. Deny by default. A missing verifier, missing configuration, failed review, expired evidence, or provider error must not grant owner privileges.
5. Do not store identity-card images by default. If retention is later justified, require explicit consent, strict access control, encryption, a retention deadline, and deletion workflow. Never log card numbers, extracted identity data, or image contents.
6. OCR and face matching are signals only; neither proves document authenticity. A human review must be described as document review, not official government verification. Only claim authoritative verification if a trusted provider can be integrated and its evidence validated server-side.
7. Keep audit records append-only where supported, recording decision metadata without raw personal data.
8. A device fingerprint/biometric prompt is not, by itself, proof of legal identity or owner status. Never collect, transmit, or store raw fingerprint/face biometric templates in TOFAN.
9. Never let a public, unauthenticated “first account wins” race claim ownership of a deployed instance. Bootstrap must be explicitly armed by the deployer and consumed atomically once.

## Implemented in the current draft
- Privacy-minimized domain metadata model and unit tests.
- Client repository that creates a pending request using the active Supabase Auth user ID and lists only that user's requests; requests for a trusted provider are rejected until a provider is actually configured.
- A new migration proposal that grants authenticated users read-own/create-pending access only; approval fields are not client-writable, and a partial unique index prevents multiple simultaneous pending requests per account.
- Client-side owner-grant minting using a caller-supplied `ownerAuthenticated` boolean has been disabled; grant issuance remains unavailable until a trusted server-side path exists.
- Removed the `TOFAN_OWNER_ACTOR_ID` compile-time client setting. The Flutter client now fails closed for local owner authority instead of treating a bundled actor ID as proof of ownership. This is a defense-in-depth hardening step, not a replacement for server-side authorization.
- Added a proposed server-only owner-assignment table and single-use atomic bootstrap RPC. The RPC requires a previously reviewed identity-verification record, rejects client execution, and permits only one owner assignment.
- Added a Supabase Edge Function that validates the caller through Supabase Auth, checks a high-entropy `TOFAN_OWNER_BOOTSTRAP_SECRET` configured only as a server-side function secret, and calls the atomic RPC with the validated account ID. It never accepts an actor ID from the request body.
- Added isolated PostgreSQL tests for client denial, unverified identity denial, successful reviewed-identity bootstrap, and rejection of a second claim. This function is not deployed and the proposed migration is not applied to a live database.
- No card image upload, OCR, face matching, reviewer endpoint, trusted provider, owner-role integration, or live migration has been implemented.

## Proposed end-to-end identity and owner lifecycle

### A. Account registration and owner bootstrap
1. All users register through the existing Supabase Auth flow; account creation alone grants no owner privileges.
2. Before public launch, the deployer must securely configure a one-time owner-bootstrap mechanism (for example, a high-entropy, single-use secret stored only server-side, or an out-of-band operator-approved claim). Do not place the secret in Flutter, source control, app configuration bundled to clients, logs, or public documentation.
3. The intended initial owner registers, authenticates, claims the bootstrap, and completes identity verification. The server consumes the bootstrap and creates the single owner assignment in one database transaction with a uniqueness/locking guarantee. Concurrent claims must result in exactly one success.
4. If the bootstrap is absent, expired, already consumed, or misconfigured, ownership remains unassigned and all privileged operations are denied. Do not silently promote whoever happens to be the first public registrant.
5. Keep an explicit recovery path for a lost bootstrap that requires deployment-operator intervention; do not add a client-side “make me owner” fallback.

### B. Verify the person and the identity document
1. Require the signed-in account and a fresh re-authentication before sensitive submission or ownership actions.
2. Prefer a reputable identity-verification provider that checks document authenticity, document validity, and (where lawful and supported) selfie liveness/face match. Validate provider webhooks/results server-side, including signatures, timestamps, audience, request ID, replay protection, and final status.
3. If no suitable provider is available, offer a clearly labeled manual review by an explicitly authorized reviewer. Do not claim automated or government verification if it did not occur.
4. Store only minimum required metadata and provider references. If document images are genuinely required, use private storage, short-lived upload URLs, strict per-request access, encryption, explicit consent, limited retention, and verified deletion. Never put biometric templates in the application database.
5. Keep identity verification distinct from account authentication and ownership assignment. A document passing review is necessary evidence, not sufficient owner authorization by itself.

### C. “Fingerprint” / biometric confirmation
1. Use platform-native authentication (Android BiometricPrompt / iOS LocalAuthentication) only to unlock a device-bound credential; the app must not receive the fingerprint itself. Device biometrics can be unavailable, changed, or enrolled differently and are not a reliable cross-device identity identifier.
2. For server-verifiable owner authentication, prefer passkeys/WebAuthn or an equivalent challenge-response credential. The private key should remain in the device/platform secure authenticator; the server stores only public-key credential metadata and verifies a fresh, single-use, origin-bound challenge.
3. Require a fresh server challenge for high-risk operations, validate challenge expiry and one-time use, and rate-limit failures. For especially sensitive operations, require step-up authentication and a second factor/recovery route rather than relying on a local biometric prompt alone.
4. Provide secure fallback for devices without biometrics and for lost/replaced devices. Fallback must not bypass identity checks or be reducible to a support agent changing a database flag.
5. Do not store a fingerprint image, fingerprint template, face template, or a client-supplied “biometric_verified=true” flag. A local biometric success callback alone must never grant a server role.

### D. Grant and enforce owner permissions
1. Only trusted server-side code may finalize verification, issue or transfer ownership, or modify owner-role records.
2. The database must enforce a single active owner assignment (or a separately designed multi-owner policy) and reject client INSERT/UPDATE/DELETE attempts against owner assignments.
3. Every privileged backend operation must check the authenticated actor, current owner assignment, required assurance/freshness, and the specific permission at the enforcement boundary. Hiding UI controls is not authorization.
4. Record security events (verification decision, credential enrollment/revocation, owner assignment/transfer) with actor, timestamp, request/correlation ID, and outcome, but no raw identity or biometric data.
5. Test direct API/database attempts, not only Flutter UI flows.

### E. Sale or transfer of the project
“Changing the fingerprint” must be implemented as a controlled owner transfer, not overwriting a fingerprint value:
1. The current owner re-authenticates with a passkey/security credential and confirms the transfer through a fresh server challenge.
2. The proposed new owner creates their own account, completes identity-document verification and enrolls their own passkey/biometric-backed credential.
3. The server creates a pending transfer, sends out-of-band notifications to both parties, applies a configurable cooling-off period, and requires explicit confirmation. A compromised current session alone must not complete the sale.
4. A trusted server-side transaction atomically assigns ownership to the new verified account, revokes or scopes down the former owner's owner credentials/sessions, rotates relevant project secrets, and appends an audit event. Failed or partial transfer must leave the old assignment intact.
5. Provide a separately secured recovery/dispute process. Never allow a new owner to inherit the former owner's biometric credential, and never let a simple fingerprint change silently transfer ownership.

## Workflow and states
- UNVERIFIED: no verification request.
- PENDING_REVIEW: request submitted and awaiting review.
- VERIFIED: passed the explicitly recorded verification method and assurance level.
- REJECTED: request rejected.
- SUSPENDED: verification temporarily disabled pending review.

Each request should track: authenticated user_id, state, method, assurance level, created/updated timestamps, reviewer or trusted-provider reference, decision reason code, and retention/deletion metadata. Avoid storing full card number, OCR payload, face template, or raw images unless a separately approved privacy/security design requires them.

## Proposed implementation sequence
1. Inspect existing authentication, owner-authority, audit, database migration, and application-service contracts before coding.
2. Define persistence and RLS policies in a new migration only; do not edit an already deployed migration or apply anything to a live Supabase project.
3. Implement a least-data verification request model and explicit state transitions. Only trusted server-side code may approve a request or record reviewer/provider decisions.
4. Replace trust in caller-supplied authentication booleans with a trusted authorization decision at the enforcement boundary; trace every grant issuer and consumer before changing APIs.
5. Design one-time owner bootstrap, server-side document verification/review, passkey enrollment/challenge verification, owner enforcement, and transfer workflow as distinct reviewed components. Do not fake biometric/provider behavior in Flutter.
6. Connect owner authorization to a separately configured canonical owner auth.uid() and test that verification status alone never grants owner privileges.
7. Add tests for unauthenticated users, another user's request, client-side status tampering, forged reviewer/provider decisions, replayed/expired challenges, competing bootstrap claims, multiple owner assignments, expired/suspended/rejected states, owner self-grant attempts, transfer rollback, audit leakage, and missing configuration.
8. Run format, static analysis, unit/integration tests against an isolated test environment. Report unavailable checks honestly.
9. Review the diff and migration before any merge, live database operation, or deployment.

## Blockers / decisions required before production
- Confirm a trustworthy identity-verification provider or explicitly approve a manual document-review process and reviewer roles.
- Configure the initial owner bootstrap securely before public launch; first public signup must not automatically become owner.
- Choose and implement a server-verifiable passkey/WebAuthn solution; native biometric prompts alone are not enough.
- Implement a trusted server-side approval/transfer service and test database constraints/RLS in an isolated environment.
- Determine applicable privacy/retention requirements before collecting any identity-card image or biometric-related information.
- Secure server-side decision-making is required; a Flutter-only client implementation is insufficient for granting owner authority.

## Acceptance criteria
- No client can grant itself owner or reviewer authority.
- Public account-registration order cannot determine ownership.
- Identity verification, device biometric unlock, passkey authentication, and project-owner authorization remain separate and explicitly enforced.
- Biometric templates and raw identity data are never stored in application records or logs.
- Per-user records are isolated by database policy.
- Ownership can be transferred only through the verified, audited, two-party high-assurance transfer workflow.
- All state transitions, bootstrap, credential recovery, and owner-transfer paths have negative security tests.
- No live migration, merge, or deployment occurs without separate review and explicit approval.
