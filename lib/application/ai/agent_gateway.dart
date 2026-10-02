import 'dart:async';

import '../../domain/execution/execution_models.dart';
import '../../domain/security/agent_authorization_models.dart';
import '../../domain/security/authentication_models.dart';
import '../../domain/security/audit_models.dart';
import '../../domain/security/audit_repository.dart';
import '../../domain/security/oc_auth_models.dart';
import '../../domain/security/owner_authority.dart';
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
    this.ownerAuthority = const OwnerAuthority(),
    AbqariExecutionCoordinator? executionCoordinator,
    AuditRecorder? auditRecorder,
    this.auditRepository,
  })  : executionCoordinator =
            executionCoordinator ?? const AbqariExecutionCoordinator(),
        auditRecorder = auditRecorder ?? AuditRecorder();

  final AgentPolicy policy;
  final OcAuthService ocAuth;
  final OwnerAuthority ownerAuthority;
  final AbqariExecutionCoordinator executionCoordinator;
  final AuditRecorder auditRecorder;
  final AuditRepository? auditRepository;

  /// Dispatches only from a currently authenticated Supabase session.
  /// The caller cannot supply or override actorId/role.
  Future<AiAgentResponse> dispatchAuthenticated({
    required AuthenticationGateway authentication,
    required AgentTask task,
    required AiAgentRequest request,
    required AiAgent agent,
    AgentExecutionRequest? execution,
    ScopedGrant? grant,
    bool ownerApproved = false,
  }) async {
    final session = await authentication.currentSession();
    if (session == null || !session.isActive) {
      throw StateError('An active authenticated session is required.');
    }

    final identity = session.identity;
    final role = TofanPrincipalRole.values.where(
      (value) => value.name == identity.role,
    ).firstOrNull ?? TofanPrincipalRole.student;

    return dispatch(
      context: AgentContext(
        actorId: identity.actorId,
        role: role,
        studentId: role == TofanPrincipalRole.student ? identity.actorId : null,
      ),
      task: task,
      request: request,
      agent: agent,
      execution: execution,
      grant: grant,
      ownerApproved: ownerApproved,
    );
  }

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

    // Normal role permissions are sufficient for ordinary operations.
    // A scoped grant is an additional constraint when explicitly supplied; it
    // is never self-issued and is never required merely because the actor is
    // not the owner.
    if (grant != null) {
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
    final event = AuditEvent(
      id: 'agent-' + DateTime.now().microsecondsSinceEpoch.toString(),
      actorId: actorId,
      action: action,
      resourceId: resourceId,
      outcome: outcome,
      timestamp: DateTime.now(),
      reason: reason,
    );
    auditRecorder.record(event);
    if (auditRepository != null) {
      unawaited(_persistAudit(event));
    }
  }

  Future<void> _persistAudit(AuditEvent event) async {
    try {
      await auditRepository!.save(event);
    } catch (_) {
      // Audit persistence failure must not alter the authorization decision.
    }
  }
}
