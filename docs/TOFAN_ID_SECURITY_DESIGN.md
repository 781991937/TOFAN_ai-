# TOFAN ID — Identity Verification and Owner Authorization Design

**Status:** Initial implementation slice in a draft PR. The domain metadata model, current-user request repository, provider registration, and proposed RLS migration exist on the feature branch. This is not a complete or production-ready identity-verification system.

## Goals
Integrate an identity-verification workflow into the existing TOFAN AI architecture without creating a parallel app or weakening current authorization. Identity verification and project-owner authorization are separate decisions.

## Security invariants
1. Supabase Auth user ID (auth.uid() / currentUser.id) is the canonical account identity. Email, display name, OCR output, client-provided flags, and a submitted document are not authentication proofs.
2. A verified identity does not automatically become the project owner. Owner status must be bound to an explicitly configured, trusted account identity and enforced server-side / by database policy.
3. The client must never be trusted to set ownerAuthenticated, a verification status, reviewer identity, or an administrative role.
4. Deny by default. A missing verifier, missing configuration, failed review, expired evidence, or provider error must not grant owner privileges.
5. Do not store identity-card images by default. If retention is later justified, require explicit consent, strict access control, encryption, a retention deadline, and deletion workflow. Never log card numbers, extracted identity data, or image contents.
6. OCR and face matching are signals only; neither proves document authenticity. A human review must be described as document review, not official government verification. Only claim authoritative verification if a trusted provider can be integrated and its evidence validated server-side.
7. Keep audit records append-only where supported, recording decision metadata without raw personal data.

## Implemented in the current draft
- Privacy-minimized domain metadata model and unit tests.
- Client repository that creates a pending request using the active Supabase Auth user ID and lists only that user's requests; requests for a trusted provider are rejected until a provider is actually configured.
- A new migration proposal that grants authenticated users read-own/create-pending access only; approval fields are not client-writable, and a partial unique index prevents multiple simultaneous pending requests per account.
- No card image upload, OCR, face matching, reviewer endpoint, trusted provider, owner-role integration, or live migration has been implemented.

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
5. Connect owner authorization to a separately configured canonical owner auth.uid() and test that verification status alone never grants owner privileges.
6. Add tests for unauthenticated users, another user's request, client-side status tampering, forged reviewer/provider decisions, expired/suspended/rejected states, owner self-grant attempts, audit leakage, and missing configuration.
7. Run format, static analysis, unit/integration tests against an isolated test environment. Report unavailable checks honestly.
8. Review the diff and migration before any merge, live database operation, or deployment.

## Blockers / decisions required before production
- Confirm a trustworthy verification method/provider is actually available. Do not assume a government API exists.
- Decide whether manual review is acceptable and who is authorized to review.
- Determine applicable privacy/retention requirements before collecting any identity-card image.
- Secure server-side decision-making is required; a Flutter-only client implementation is insufficient for granting owner authority.

## Acceptance criteria
- No client can grant itself owner or reviewer authority.
- Identity status and project-owner authorization remain independent.
- Per-user records are isolated by database policy.
- No raw identity data appears in logs or routine audit events.
- All state transitions and owner-grant paths have negative security tests.
- No live migration, merge, or deployment occurs without separate review and explicit approval.