import '../../domain/execution/execution_models.dart';

/// Owner authority must be bound to a trusted authenticated actor ID.
/// No email address or implicit fallback is accepted as owner proof.
class OwnerAuthority {
  const OwnerAuthority({this.ownerActorId});

  final String? ownerActorId;

  bool isOwner(String actorId) {
    final configured = ownerActorId?.trim();
    final candidate = actorId.trim();
    if (configured == null || configured.isEmpty || candidate.isEmpty) {
      return false;
    }
    return candidate == configured;
  }

  bool hasPermission(String actorId, ToolPermission permission) =>
      isOwner(actorId) && ToolPermission.values.contains(permission);

  bool hasAllPermissions(String actorId) =>
      isOwner(actorId) &&
      ToolPermission.values.every(
        (permission) => hasPermission(actorId, permission),
      );
}
