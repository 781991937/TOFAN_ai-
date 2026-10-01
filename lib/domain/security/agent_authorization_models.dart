enum TofanPrincipalRole { student, tutor, manager, owner }

enum AgentPermission { readAcademic, updateStudentState, assess, manageProjects, useTools, administer }

class AgentContext {
  const AgentContext({
    required this.actorId,
    required this.role,
    this.studentId,
  });

  final String actorId;
  final TofanPrincipalRole role;
  final String? studentId;
}

class AgentTask {
  const AgentTask({
    required this.id,
    required this.agentRole,
    required this.operation,
    required this.resource,
  });

  final String id;
  final String agentRole;
  final String operation;
  final String resource;
}

class AgentAuthorization {
  const AgentAuthorization({
    required this.allowed,
    required this.reason,
    this.permissions = const [],
  });

  final bool allowed;
  final String reason;
  final List<AgentPermission> permissions;
}

class AgentPolicy {
  const AgentPolicy();

  AgentAuthorization authorize({
    required AgentContext context,
    required AgentTask task,
  }) {
    if (context.actorId.trim().isEmpty) {
      return const AgentAuthorization(
        allowed: false,
        reason: 'Missing actor identity.',
      );
    }

    final permissions = switch (context.role) {
      TofanPrincipalRole.student => const [
          AgentPermission.readAcademic,
          AgentPermission.updateStudentState,
          AgentPermission.assess,
          AgentPermission.manageProjects,
        ],
      TofanPrincipalRole.tutor => const [
          AgentPermission.readAcademic,
          AgentPermission.assess,
          AgentPermission.manageProjects,
        ],
      TofanPrincipalRole.manager => const [
          AgentPermission.readAcademic,
          AgentPermission.updateStudentState,
          AgentPermission.assess,
          AgentPermission.manageProjects,
          AgentPermission.useTools,
        ],
      TofanPrincipalRole.owner => AgentPermission.values,
    };

    final required = _permissionFor(task.operation);
    if (!permissions.contains(required)) {
      return AgentAuthorization(
        allowed: false,
        reason: 'Permission denied for operation: ${task.operation}.',
        permissions: List.unmodifiable(permissions),
      );
    }

    return AgentAuthorization(
      allowed: true,
      reason: 'Authorized by explicit role policy.',
      permissions: List.unmodifiable(permissions),
    );
  }

  AgentPermission _permissionFor(String operation) {
    switch (operation.toLowerCase()) {
      case 'read':
      case 'search':
      case 'retrieve':
        return AgentPermission.readAcademic;
      case 'student.update':
        return AgentPermission.updateStudentState;
      case 'assessment':
        return AgentPermission.assess;
      case 'project':
        return AgentPermission.manageProjects;
      case 'tool.execute':
        return AgentPermission.useTools;
      case 'admin':
        return AgentPermission.administer;
      default:
        return AgentPermission.useTools;
    }
  }
}
