/// Identity-verification metadata only. This model deliberately excludes
/// identity-card numbers, OCR payloads, face templates, and raw document images.
///
/// A client-side instance is not proof of verification. Authorization decisions
/// must use the trusted persisted state written by a server-side reviewer/provider.
enum IdentityVerificationStatus {
  unverified,
  pendingReview,
  verified,
  rejected,
  suspended,
}

/// The verification path requested or used for a record.
enum IdentityVerificationMethod {
  manualDocumentReview,
  trustedProvider,
}

/// Assurance label describing what the recorded process actually established.
enum IdentityAssuranceLevel {
  none,
  documentReviewed,
  providerVerified,
}

/// Privacy-minimized verification metadata; never stores the document itself.
class IdentityVerificationRecord {
  const IdentityVerificationRecord({
    required this.id,
    required this.userId,
    required this.status,
    required this.method,
    required this.assuranceLevel,
    required this.createdAt,
    required this.updatedAt,
    this.reviewerActorId,
    this.providerReference,
    this.reasonCode,
    this.reviewedAt,
  });

  final String id;
  /// Canonical Supabase Auth user UUID; not an email or display name.
  final String userId;
  final IdentityVerificationStatus status;
  final IdentityVerificationMethod method;
  final IdentityAssuranceLevel assuranceLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// Internal reviewer identity only; must be assigned by trusted server code.
  final String? reviewerActorId;
  /// Opaque reference only. Do not put document data or OCR output here.
  final String? providerReference;
  /// Non-sensitive reason code, never a full identity document or OCR response.
  final String? reasonCode;
  final DateTime? reviewedAt;

  bool get isPending => status == IdentityVerificationStatus.pendingReview;

  /// Informational only. This is NOT an owner-authorization decision.
  bool get hasRecordedVerification =>
      status == IdentityVerificationStatus.verified &&
      assuranceLevel != IdentityAssuranceLevel.none;
}
