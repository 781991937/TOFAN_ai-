import '../../domain/execution/execution_models.dart';
import '../../domain/security/agent_authorization_models.dart';
import '../../domain/security/audit_models.dart';
import '../../domain/security/oc_auth_models.dart';
import '../execution/abqari_execution_coordinator.dart';
import 'agent_state.dart';

class AgentExecutionRequest {
  const AgentExecutionRequest({
    required this.toolId,
    required this.authorization,
    required this.workspaceRequest,
  });

  final String toolId;
  final ToolAuthorization authorization;
  final WorkspaceRequest workspaceRequest;
}

class AgentGateway {
  AgentGateway({
    this.policy = const AgentPolicy(),
    this.ocAuth = const OcAuthService(),
    AbqariExecutionCoordinator? executionCoordinator,
    AuditRecorder? auditRecorder,
  })  : executionCoordinator =
            executionCoordinator ?? const AbqariExecutionCoordinator(),
        auditRecorder = auditRecorder ?? AuditRecorder();

  final AgentPolicy policy;
  final OcAuthService ocAuth;
  final AbqariExecutionCoordinator executionCoordinator;
  final AuditRecorder auditRecorder;

  static const String ownerActorId = 'raedtofan86@gmail.com';

  Future<AiAgentResponse> dispatch({
    required AgentContext context,
    required AgentTask task,
    required AiAgentRequest request,
    required AiAgent agent,
    AgentExecutionRequest? execution,
    ScopedGrant? grant,
    bool ownerApproved = false,
  }) async {
    final action = task.operation;
    final resource = task.resource;

    if (context.actorId.trim().isEmpty) {
      _audit(context.actorId, action, resource, AuditOutcome.denied,
          'Missing actor identity.');
      throw StateError('Missing actor identity.');
    }

    if (request.role != agent.role) {
      _audit(context.actorId, action, resource, AuditOutcome.denied,
          'Request role does not match target agent.');
      throw ArgumentError('Request role does not match target agent.');
    }

    final agentAuthorization = policy.authorize(
      context: context,
      task: task,
    );
    if (!agentAuthorization.allowed) {
      _audit(context.actorId, action, resource, AuditOutcome.denied,
          agentAuthorization.reason);
      throw StateError(agentAuthorization.reason);
    }

    // The configured owner identity has all system permissions and does not
    // require a self-issued scoped grant.
    if (context.actorId != ownerActorId) {
      if (grant == null) {
        _audit(context.actorId, action, resource, AuditOutcome.denied,
            'Owner-scoped grant is required.');
        throw StateError('Owner-scoped grant is required.');
      }
      final ownerDecision = ocAuth.authorize(
        actorId: context.actorId,
        operation: action,
        resourceId: resource,
        grant: grant,
        ownerApproved: ownerApproved,
      );
      if (!ownerDecision.allowed) {
        _audit(context.actorId, action, resource, AuditOutcome.denied,
            ownerDecision.reason);
        throw StateError(ownerDecision.reason);
      }
    }

    final requiresExecutionAuthorization =
        action.toLowerCase() == 'tool.execute' || execution != null;
    if (requiresExecutionAuthorization) {
      if (execution == null) {
        _audit(context.actorId, action, resource, AuditOutcome.denied,
            'Tool and workspace authorization are required.');
        throw StateError('Tool and workspace authorization are required.');
      }
      if (execution.authorization.actorId != context.actorId) {
        _audit(context.actorId, action, resource, AuditOutcome.denied,
            'Tool authorization actor does not match agent context.');
        throw StateError(
            'Tool authorization actor does not match agent context.');
      }
      if (!executionCoordinator.authorize(
        toolId: execution.toolId,
        authorization: execution.authorization,
        workspaceRequest: execution.workspaceRequest,
      )) {
        _audit(context.actorId, action, resource, AuditOutcome.denied,
            'Tool or workspace authorization denied.');
        throw StateError('Tool or workspace authorization denied.');
      }
    }

    final response = await agent.handle(request);
    _audit(context.actorId, action, resource, AuditOutcome.success,
        'Agent request completed.');
    return response;
  }

  void _audit(
    String actorId,
    String action,
    String resourceId,
    AuditOutcome outcome,
    String reason,
  ) {
    auditRecorder.record(
      AuditEvent(
        id: 'agent-' + DateTime.now().microsecondsSinceEpoch.toString(),
        actorId: actorId,
        action: action,
        resourceId: resourceId,
        outcome: outcome,
        timestamp: DateTime.now(),
        reason: reason,
      ),
    );
  }
}
