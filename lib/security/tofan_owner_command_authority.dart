enum OwnerPermission { read, search, write, export, administer, execute }

class OwnerCommandGrant {
  const OwnerCommandGrant._({
    required this.ownerIdentity,
    required this.commandId,
    required this.agentId,
    required this.resourceScope,
    required this.permission,
    required this.action,
    required this.issuedAt,
    required this.expiresAt,
    required this.reason,
    this.approval = 'OWNER_AUTHENTICATED',
  });

  final String ownerIdentity;
  final String commandId;
  final String agentId;
  final String resourceScope;
  final OwnerPermission permission;
  final String action;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String reason;
  final String approval;

  bool isActive(DateTime now) =>
      approval == 'OWNER_AUTHENTICATED' &&
      ownerIdentity.trim().isNotEmpty &&
      agentId == 'TOFAN_ABQARI' &&
      expiresAt.isAfter(now) &&
      !expiresAt.isBefore(issuedAt);

  bool covers({required String resource, required OwnerPermission requestedPermission}) =>
      permission == requestedPermission &&
      (resource == resourceScope ||
          resourceScope == '*' ||
          (resourceScope.endsWith('/*') &&
              resource.startsWith(resourceScope.substring(0, resourceScope.length - 1))));
}

class TofanOwnerCommandAuthority {
  const TofanOwnerCommandAuthority._();

  /// Grant issuance is intentionally unavailable in the Flutter client.
  /// A caller-controlled boolean is not proof of owner authentication. Add a
  /// server-side, authenticated issuance path before enabling owner grants.

  static bool authorize({
    required OwnerCommandGrant? grant,
    required String resource,
    required OwnerPermission permission,
    required DateTime now,
  }) =>
      grant != null &&
      grant.isActive(now) &&
      grant.covers(resource: resource, requestedPermission: permission);
}
