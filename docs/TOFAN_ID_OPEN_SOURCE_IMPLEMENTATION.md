# TOFAN ID — Open-Source, Self-Hosted Verification Plan

**Status:** implementation contract; not a claim that document verification or passkeys are already operational.
**Target:** keep TOFAN ID in the existing TOFAN AI repository and use self-hosted/open-source components by default. Paid identity-verification vendors are optional adapters, never a mandatory dependency.

## Product decision

TOFAN ID must distinguish these outcomes:
- `DOCUMENT_DATA_EXTRACTED`: OCR extracted readable fields; this is not verification.
- `DOCUMENT_CONSISTENCY_CHECKED`: format and internal consistency checks passed; this is not proof the document is genuine.
- `FACE_MATCH_SIGNAL`: a face-comparison model returned a score; this is not proof of liveness or legal identity.
- `LIVENESS_SIGNAL`: a tested anti-spoofing check passed within its stated limitations.
- `MANUAL_REVIEW_APPROVED`: an authorized reviewer inspected the evidence; describe this as manual review, not government verification.
- `AUTHORITATIVELY_VERIFIED`: allowed only when a trusted issuing authority or trusted verification provider returns a server-validated result.

No lower assurance level may be promoted to a higher one by a client-side flag or a model score alone.

## Proposed no-mandatory-fee architecture

### 1. Flutter client (existing app)
- Continue using the existing Supabase Auth identity as the canonical account.
- Request camera permission only when the user begins verification; explain purpose, retention, and deletion first.
- Upload only to a private quarantine area through a short-lived, user-scoped upload path; never use public buckets.
- Do not bundle OCR/face-model weights into the mobile app for security decisions.
- Never collect, upload, or store fingerprint images/templates. Use platform passkeys/WebAuthn for server-verifiable step-up authentication where supported.

### 2. Self-hosted verification worker (new service, separately deployable)
- Python API worker, isolated from the public Flutter client and not exposed as an unrestricted file-processing endpoint.
- OCR adapter: prefer a locally installed open-source OCR engine (evaluate Tesseract and PaddleOCR for Arabic/Yemeni ID samples before choosing); store extracted fields only when necessary and with strict access/retention controls.
- Image-quality and tamper triage: use OpenCV-based checks as risk signals, never as a guarantee of authenticity.
- Face comparison/liveness: only add models after checking their license, training-data provenance, Arabic/Yemeni document suitability, presentation-attack performance, and CPU/RAM requirements. A face match is not a liveness result; a liveness result is not an authoritative document check.
- The worker must authenticate requests, enforce size/type limits, reject malformed images, rate-limit, isolate decoding/model execution, avoid logging sensitive payloads, and return a versioned result plus reason codes.
- Run in a private network or behind authenticated server-to-server access. Keep all secrets server-side.

### 3. Supabase persistence and trusted decision boundary
- Store workflow metadata and result reason codes, not raw card numbers, OCR dumps, face templates, or document images by default.
- Keep evidence in private quarantine storage only for the minimum approved review window; deletion must be verifiable and audited.
- Client may create a pending request and read its own status only. Client cannot set reviewer, verification status, assurance level, owner assignment, or transfer outcome.
- A server-side Edge Function or equivalent trusted service validates the worker response, binds it to the expected request/user, prevents replay, and records the decision.
- RLS is defense in depth, not a substitute for server-side authorization. Test direct REST/database calls as well as the UI.

### 4. Passkeys and local biometrics
- Use WebAuthn/passkeys through a maintained, audited server library; do not implement cryptographic verification by hand.
- The device may use fingerprint, face unlock, PIN, or another platform method to unlock its authenticator. TOFAN receives a signed challenge assertion, not the biometric itself.
- Validate challenge freshness, one-time use, relying-party ID/origin, signature, credential status, and user-presence/user-verification flags server-side.
- Provide a carefully secured recovery route. A client callback such as `biometricVerified=true` must never authorize an owner operation.

### 5. One-time owner bootstrap and ownership transfer
- Do not let the first public registrant claim ownership automatically.
- Arm bootstrap out-of-band by the deployer using a high-entropy single-use secret stored only server-side, or an equivalent operator-approved mechanism.
- Consume the bootstrap and create the unique owner assignment atomically on the server/database. If bootstrap is absent or invalid, keep ownership unassigned.
- Owner transfer is a separate server transaction: re-authenticate current owner, verify new owner, require explicit confirmation from both, notify both, apply a cooling-off window, atomically change the owner, revoke old owner credentials/sessions, rotate relevant secrets, and append an audit event.
- Do not implement production ownership transfer until recovery, concurrency, dispute, and rollback behavior have tests.

## Delivery sequence and acceptance gates

1. **Inventory (first):** inspect existing Supabase schema, migrations, storage buckets, edge functions, audit repository, owner-authority call sites, and CI. Extend existing components; do not create duplicate auth/owner/catalog systems.
2. **Safe workflow foundation:** add request/evidence metadata states, server-owned decision fields, strict upload constraints, private quarantine and deletion policy. No production secrets or live migration in source changes.
3. **OCR prototype:** run candidate engines against a consented, representative test set that contains no real users' IDs in the repository. Measure Arabic character/field accuracy and record limitations. Do not approve identity automatically from OCR.
4. **Review path:** implement a server-authorized manual reviewer workflow with audit events. Until a reviewer or trusted provider exists, requests remain pending and owner privileges stay denied.
5. **Passkeys:** add server challenge creation/verification using a maintained library and tests for replay, expired challenge, wrong origin, invalid signature, and revoked credential.
6. **Owner bootstrap:** add atomic single-claim behavior and concurrency tests; prove a normal registrant cannot become owner.
7. **Optional model signals:** add tamper triage, face comparison, and liveness only after license/security/accuracy review; each result remains a signal unless independently validated.
8. **Transfer:** implement only after bootstrap, passkeys, audit, and server-side owner enforcement pass their gates.
9. **Validation:** CI tests, isolated Supabase integration tests, RLS cross-user tests, storage-access tests, upload abuse tests, and a security review before merge/deployment.

## Non-negotiable acceptance tests

- No signed-in user can read another user's request or evidence.
- Client cannot write `verified`, reviewer IDs, assurance levels, owner IDs, or transfer outcomes.
- OCR/face/liveness failure, worker timeout, unavailable model, missing configuration, or malformed provider response fails closed.
- OCR success and face-match success alone never yield `AUTHORITATIVELY_VERIFIED`.
- Two concurrent bootstrap claims yield exactly one owner.
- An ordinary first registrant cannot become owner without the armed bootstrap and required verification.
- No fingerprint/face biometric template or raw ID image is written to logs, source control, or general-purpose tables.
- Expired/replayed WebAuthn challenges are rejected.
- Ownership transfer failure leaves the current owner intact.
- No live migration, merge, or deployment occurs without separate review and explicit approval.

## Current known limitation

The current draft has metadata models, a client request repository, a proposed RLS migration, and owner-grant hardening. It does **not** yet contain the OCR worker, secure document upload/review endpoint, passkey server, bootstrap service, or ownership-transfer service. This document specifies the next implementation path; it does not mark those components as complete.


## Explicit owner decision from product owner (2026-10-13)

The national ID card is **only an information-entry/document-data source** for the user's profile. It must not be treated as a shared owner credential, a transferable owner token, or the mechanism that grants project ownership. Extract only the fields the user explicitly needs, show them for confirmation, and minimize retention; the card itself does not establish TOFAN project ownership.

Project ownership is a separate security role. The owner's biometric step is **the fingerprint/biometric check performed locally by the device's operating system through a passkey/platform authenticator**. TOFAN must verify the server-side cryptographic assertion; it must not receive or store the owner's fingerprint image/template. Where fingerprint-capable hardware is unavailable, the platform may offer another supported authenticator/recovery path, but it must not silently claim a fingerprint check occurred.

Therefore:
- ID-card information collection and owner authentication are separate workflows and separate data models.
- A card upload, OCR result, or extracted identity field never grants or transfers owner privileges.
- Registering an account or being the first registrant never grants owner privileges by itself.
- Owner enrollment/assignment must be established by a secure, one-time server-side bootstrap and then bound to a passkey credential after successful local user verification.
- Any future owner transfer must require the current owner's fresh passkey assertion plus explicit, independently authenticated acceptance by the new owner, with audit and recovery controls.
- UI wording must accurately say “device biometric/passkey authentication”; do not imply TOFAN directly scans or stores a fingerprint.


## Implementation status and tracked blockers (2026-10-13)

Tracking issue: [#3 — Implement passkey-backed owner authentication and one-time owner bootstrap](https://github.com/781991937/TOFAN_ai-/issues/3).

### Implemented in this branch
- Identity-verification request metadata model and current-user-scoped Supabase repository.
- Proposed RLS migration that allows a signed-in user to create a pending request and read their own request metadata; it does not let the client approve a request.
- Client-side owner-grant minting from a caller-provided `ownerAuthenticated` boolean is disabled.
- Security design separates card-data entry, account authentication, platform biometric unlock, passkey authentication, and owner authorization.

### Not implemented; must not be represented as working
- Passkey registration/login UX and a server-verified WebAuthn challenge/credential lifecycle.
- An atomic, operator-armed one-time owner bootstrap and database-enforced owner assignment.
- Server-side enforcement connecting the owner assignment to every privileged operation.
- ID-card image upload, OCR extraction, profile-field confirmation UI, manual-review endpoint, or trusted issuing-authority/provider verification.
- Secure ownership transfer, lost-device recovery, or production RLS/Edge Function integration tests.

### Current delivery boundary
This branch is still a draft. The migration remains a proposal and has not been applied. No production secrets were configured, no live database was changed, and no merge or deployment was performed. Implementation must proceed against the existing architecture and be tested in an isolated environment before any production enablement.
