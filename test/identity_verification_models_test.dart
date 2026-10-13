import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';
import 'package:tofan_ai/domain/security/identity_verification_models.dart';
import 'package:tofan_ai/domain/security/owner_authority.dart';

void main() {
  final createdAt = DateTime.utc(2026, 10, 13);

  IdentityVerificationRecord record({
    IdentityVerificationStatus status =
        IdentityVerificationStatus.pendingReview,
    IdentityAssuranceLevel assurance = IdentityAssuranceLevel.none,
  }) =>
      IdentityVerificationRecord(
        id: 'request-1',
        userId: 'auth-user-1',
        status: status,
        method: IdentityVerificationMethod.manualDocumentReview,
        assuranceLevel: assurance,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  test('pending request is represented without sensitive document fields', () {
    final request = record();
    expect(request.isPending, isTrue);
    expect(request.hasRecordedVerification, isFalse);
    expect(request.reviewerActorId, isNull);
    expect(request.providerReference, isNull);
  });

  test('verified status with no assurance is not treated as verified evidence', () {
    final request = record(status: IdentityVerificationStatus.verified);
    expect(request.hasRecordedVerification, isFalse);
  });

  test('recorded document review is distinct from provider verification', () {
    final reviewed = record(
      status: IdentityVerificationStatus.verified,
      assurance: IdentityAssuranceLevel.documentReviewed,
    );
    final providerVerified = IdentityVerificationRecord(
      id: 'request-2',
      userId: 'auth-user-2',
      status: IdentityVerificationStatus.verified,
      method: IdentityVerificationMethod.trustedProvider,
      assuranceLevel: IdentityAssuranceLevel.providerVerified,
      createdAt: createdAt,
      updatedAt: createdAt,
      reviewedAt: createdAt,
      providerReference: 'opaque-provider-ref',
    );
    expect(reviewed.hasRecordedVerification, isTrue);
    expect(providerVerified.hasRecordedVerification, isTrue);
    expect(reviewed.method, IdentityVerificationMethod.manualDocumentReview);
    expect(providerVerified.assuranceLevel, IdentityAssuranceLevel.providerVerified);
  });


  test('verified identity does not grant project-owner authority', () {
    final request = record(
      status: IdentityVerificationStatus.verified,
      assurance: IdentityAssuranceLevel.documentReviewed,
    );
    const unconfiguredOwnerAuthority = OwnerAuthority();
    expect(request.hasRecordedVerification, isTrue);
    expect(
      unconfiguredOwnerAuthority.hasPermission(
        request.userId,
        ToolPermission.administer,
      ),
      isFalse,
    );
  });

  test('rejected and suspended records are not verified', () {
    expect(
      record(status: IdentityVerificationStatus.rejected).hasRecordedVerification,
      isFalse,
    );
    expect(
      record(status: IdentityVerificationStatus.suspended).hasRecordedVerification,
      isFalse,
    );
  });
}
