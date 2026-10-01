enum ToolPermission { read, search, write, export, administer, execute }

enum WorkspacePermission { read, write, execute, network }

enum ExecutionOutcome { success, partial, failure, blocked }

enum ErrorClass { validation, authorization, workspace, execution, test, unknown }

class ToolContract {
  const ToolContract({
    required this.id,
    required this.operation,
    required this.resource,
    required this.permissions,
    this.risk = 0,
  });
  final String id;
  final String operation;
  final String resource;
  final List<ToolPermission> permissions;
  final int risk;
}

class WorkspacePolicy {
  const WorkspacePolicy({
    required this.allowedCommands,
    this.blockedCommands = const [],
    this.timeoutSeconds = 30,
    this.maxOutputBytes = 1024 * 1024,
    this.networkAllowed = false,
  });
  final List<String> allowedCommands;
  final List<String> blockedCommands;
  final int timeoutSeconds;
  final int maxOutputBytes;
  final bool networkAllowed;

  bool allowsCommand(String command) {
    final normalized = command.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (blockedCommands.any((item) => normalized.startsWith(item.toLowerCase()))) {
      return false;
    }
    return allowedCommands.any((item) => normalized.startsWith(item.toLowerCase()));
  }
}

class ToolAuthorization {
  const ToolAuthorization({
    required this.actorId,
    required this.permissions,
    this.resourceScope = const [],
  });
  final String actorId;
  final List<ToolPermission> permissions;
  final List<String> resourceScope;

  bool permits(ToolPermission permission) => permissions.contains(permission);
  bool permitsResource(String resource) =>
      resourceScope.isEmpty || resourceScope.contains(resource);
}

class WorkspaceRequest {
  const WorkspaceRequest({required this.command, required this.workspaceId});
  final String command;
  final String workspaceId;
}

class ExecutionResult {
  const ExecutionResult({
    required this.outcome,
    required this.stdout,
    required this.stderr,
    required this.exitCode,
    required this.durationMs,
  });
  final ExecutionOutcome outcome;
  final String stdout;
  final String stderr;
  final int exitCode;
  final int durationMs;
}

class TestEvidence {
  const TestEvidence({
    required this.testId,
    required this.passed,
    required this.observation,
  });
  final String testId;
  final bool passed;
  final String observation;
}

class CapabilityVerification {
  const CapabilityVerification({
    required this.capabilityId,
    required this.verified,
    required this.requiredSkillIds,
    required this.passedTestIds,
    required this.evidence,
    this.reason = '',
  });
  final String capabilityId;
  final bool verified;
  final List<String> requiredSkillIds;
  final List<String> passedTestIds;
  final List<TestEvidence> evidence;
  final String reason;
}

class CorrectionPlan {
  const CorrectionPlan({
    required this.errorClass,
    required this.affectedComponent,
    required this.rootCause,
    required this.actions,
  });
  final ErrorClass errorClass;
  final String affectedComponent;
  final String rootCause;
  final List<String> actions;
}

class ExecutionTrace {
  const ExecutionTrace({
    required this.task,
    required this.plan,
    required this.outcome,
    this.errors = const [],
    this.corrections = const [],
    this.tests = const [],
    this.evidence = const [],
  });
  final String task;
  final List<String> plan;
  final ExecutionOutcome outcome;
  final List<String> errors;
  final List<CorrectionPlan> corrections;
  final List<TestEvidence> tests;
  final List<String> evidence;
}
