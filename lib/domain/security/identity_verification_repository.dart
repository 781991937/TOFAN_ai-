import 'identity_verification_models.dart';

/// Client-facing operations for a user's own verification request metadata.
/// Approval/rejection operations are intentionally absent from this interface.
abstract interface class IdentityVerificationRepository {
  Future<IdentityVerificationRecord> createRequest({
    required IdentityVerificationMethod method,
  });

  Future<List<IdentityVerificationRecord>> loadMyRequests();
}
