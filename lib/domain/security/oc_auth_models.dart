import '../../domain/execution/execution_models.dart';

enum OcAuthGrantScope { academic, student, tool, workspace, administration }

class OwnerIdentity {
  const OwnerIdentity({required this.actorId});
  final String actorId;
}

class ScopedGrant {
  const ScopedGrant({
    required this.grantId,
    required this.ownerId,
    required this.subjectId,
    required this.scope,
    required this.resourceId,
    required this.permissions,
    required this.expiresAt,
    this.requiresOwnerApproval = false,
  });

  final String grantId;
  final String ownerId;
  final String subjectId;
  final OcAuthGrantScope scope;
  final String resourceId;
  final List<ToolPermission> permissions;
  final DateTime expiresAt;
  final bool requiresOwnerApproval;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool permits(ToolPermission permission, String resourceId) =>
      !isExpired &&
      this.resourceId == resourceId &&
      permissions.contains(permission);
}

class OcAuthDecision {
  const OcAuthDecision({
    required this.allowed,
    required this.reason,
  });
  final bool allowed;
  final String reason;
}

class OcAuthPolicy {
  const OcAuthPolicy();

  OcAuthDecision authorize({
    required String actorId,
    required String operation,
    required String resourceId,
    required ScopedGrant grant,
    bool ownerApproved = false,
  }) {
    if (actorId.trim().isEmpty) {
      return const OcAuthDecision(allowed: false, reason: 'Missing actor identity.');
    }
    if (grant.ownerId == grant.subjectId) {
      return const OcAuthDecision(allowed: false, reason: 'Self-grant is forbidden.');
    }
    if (grant.ownerId.trim().isEmpty || grant.subjectId.trim().isEmpty) {
      return const OcAuthDecision(allowed: false, reason: 'Grant identity is incomplete.');
    }
    if (grant.subjectId != actorId) {
      return const OcAuthDecision(allowed: false, reason: 'Grant subject does not match actor.');
    }
    if (grant.isExpired) {
      return const OcAuthDecision(allowed: false, reason: 'Grant has expired.');
    }
    if (grant.requiresOwnerApproval && !ownerApproved) {
      return const OcAuthDecision(allowed: false, reason: 'Owner approval is required.');
    }
    final permission = _permissionFor(operation);
    if (!grant.permits(permission, resourceId)) {
      return const OcAuthDecision(allowed: false, reason: 'Scoped permission denied.');
    }
    return const OcAuthDecision(allowed: true, reason: 'Authorized by scoped owner grant.');
  }

  ToolPermission _permissionFor(String operation) {
    switch (operation.toLowerCase()) {
      case 'read':
        return ToolPermission.read;
      case 'search':
        return ToolPermission.search;
      case 'write':
        return ToolPermission.write;
      case 'export':
        return ToolPermission.export;
      case 'admin':
      case 'administer':
        return ToolPermission.administer;
      case 'execute':
      case 'tool.execute':
        return ToolPermission.execute;
      default:
        return ToolPermission.read;
    }
  }
}

class OcAuthService {
  const OcAuthService({this.policy = const OcAuthPolicy()});
  final OcAuthPolicy policy;

  OcAuthDecision authorize({
    required String actorId,
    required String operation,
    required String resourceId,
    required ScopedGrant grant,
    bool ownerApproved = false,
  }) =>
      policy.authorize(
        actorId: actorId,
        operation: operation,
        resourceId: resourceId,
        grant: grant,
        ownerApproved: ownerApproved,
      );
}
