import 'api_models.dart';

/// Server-side owner authorization policy.
///
/// The principal must come from Supabase Auth's verified /auth/v1/user
/// response. In particular, [ApiPrincipal.role] must be sourced from
/// app_metadata, never user_metadata or request JSON.
class OwnerAuthorizationPolicy {
  OwnerAuthorizationPolicy({required String ownerUserId})
    : _ownerUserId = ownerUserId.trim().toLowerCase();

  final String _ownerUserId;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  bool get isConfigured => _uuidPattern.hasMatch(_ownerUserId);

  bool allows(ApiPrincipal principal) =>
      isConfigured &&
      principal.userId.toLowerCase() == _ownerUserId &&
      principal.role == 'owner';

  /// Throws closed when owner identity is not configured or does not match.
  void requireOwner(ApiPrincipal principal) {
    if (!isConfigured) {
      throw const ApiException(
        503,
        'owner_authorization_not_configured',
        'Owner authorization is not configured on this server.',
      );
    }
    if (!allows(principal)) {
      throw const ApiException(
        403,
        'owner_required',
        'This operation requires the configured owner account.',
      );
    }
  }
}
