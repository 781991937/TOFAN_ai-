import '../../domain/execution/execution_models.dart';

class OwnerAuthority {
  const OwnerAuthority({this.ownerActorId = 'raedtofan86@gmail.com'});

  final String ownerActorId;

  bool isOwner(String actorId) =>
      actorId.trim().toLowerCase() == ownerActorId.toLowerCase();

  bool hasPermission(String actorId, ToolPermission permission) =>
      isOwner(actorId) && ToolPermission.values.contains(permission);

  bool hasAllPermissions(String actorId) =>
      isOwner(actorId) && ToolPermission.values.every(
            (permission) => hasPermission(actorId, permission),
          );
}
