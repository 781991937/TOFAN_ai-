import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/security/identity_verification_models.dart';
import '../../domain/security/identity_verification_repository.dart';

/// Supabase client adapter. It derives user_id from the active Auth session;
/// callers cannot submit an arbitrary user ID or set a decision/status.
class SupabaseIdentityVerificationRepository
    implements IdentityVerificationRepository {
  SupabaseIdentityVerificationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String _requireCurrentUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('An active Supabase user is required.');
    }
    return userId;
  }

  @override
  Future<IdentityVerificationRecord> createRequest({
    required IdentityVerificationMethod method,
  }) async {
    if (method != IdentityVerificationMethod.manualDocumentReview) {
      throw UnsupportedError(
        'Trusted-provider verification is unavailable until a provider is configured.',
      );
    }
    final userId = _requireCurrentUserId();
    final row = await _client
        .from('identity_verification_requests')
        .insert({
          'user_id': userId,
          'method': _methodToDatabase(method),
        })
        .select()
        .single();
    return _recordFromRow(row);
  }

  @override
  Future<List<IdentityVerificationRecord>> loadMyRequests() async {
    final userId = _requireCurrentUserId();
    final rows = await _client
        .from('identity_verification_requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map(_recordFromRow).toList(growable: false);
  }

  String _methodToDatabase(IdentityVerificationMethod method) {
    switch (method) {
      case IdentityVerificationMethod.manualDocumentReview:
        return 'manual_document_review';
      case IdentityVerificationMethod.trustedProvider:
        return 'trusted_provider';
    }
  }

  IdentityVerificationRecord _recordFromRow(Map<String, dynamic> row) {
    return IdentityVerificationRecord(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      status: _statusFromDatabase(row['status'] as String),
      method: _methodFromDatabase(row['method'] as String),
      assuranceLevel: _assuranceFromDatabase(row['assurance_level'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      reviewerActorId: row['reviewer_actor_id'] as String?,
      providerReference: row['provider_reference'] as String?,
      reasonCode: row['reason_code'] as String?,
      reviewedAt: row['reviewed_at'] == null
          ? null
          : DateTime.parse(row['reviewed_at'] as String),
    );
  }

  IdentityVerificationStatus _statusFromDatabase(String value) {
    switch (value) {
      case 'pending_review':
        return IdentityVerificationStatus.pendingReview;
      case 'verified':
        return IdentityVerificationStatus.verified;
      case 'rejected':
        return IdentityVerificationStatus.rejected;
      case 'suspended':
        return IdentityVerificationStatus.suspended;
      default:
        throw FormatException('Unknown identity verification status: $value');
    }
  }

  IdentityVerificationMethod _methodFromDatabase(String value) {
    switch (value) {
      case 'manual_document_review':
        return IdentityVerificationMethod.manualDocumentReview;
      case 'trusted_provider':
        return IdentityVerificationMethod.trustedProvider;
      default:
        throw FormatException('Unknown identity verification method: $value');
    }
  }

  IdentityAssuranceLevel _assuranceFromDatabase(String value) {
    switch (value) {
      case 'none':
        return IdentityAssuranceLevel.none;
      case 'document_reviewed':
        return IdentityAssuranceLevel.documentReviewed;
      case 'provider_verified':
        return IdentityAssuranceLevel.providerVerified;
      default:
        throw FormatException('Unknown identity assurance level: $value');
    }
  }
}
