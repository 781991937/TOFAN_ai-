import 'dart:async';
import 'dart:developer' as developer;

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
    this.onAuditPersistenceFailure,
  }) : executionCoordinator =
           executionCoordinator ?? const AbqariExecutionCoordinator(),
       auditRecorder = auditRecorder ?? AuditRecorder();

  final AgentPolicy policy;
  final OcAuthService ocAuth;
  final OwnerAuthority ownerAuthority;
  final AbqariExecutionCoordinator executionCoordinator;
  final AuditRecorder auditRecorder;
  final AuditRepository? auditRepository;
  final void Function(Object error, AuditEvent event)?
  onAuditPersistenceFailure;

  Future<AiAgentResponse> dispatchAuthenticated({
    required AuthenticationGateway authentication,
    required AgentTask task,
    required AiAgentRequest request,
    required AiAgent agent,
    AgentExecutionRequest? execution,
    ScopedGrant? grant,
    OwnerApproval? ownerApproval,
  }) async {
    final session = await authentication.currentSession();
    if (session == null || !session.isActive) {
      throw StateError('An active authenticated session is required.');
    }

    final identity = session.identity;
    final role =
        TofanPrincipalRole.values
            .where((value) => value.name == identity.role)
            .firstOrNull ??
        TofanPrincipalRole.student;

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
      ownerApproval: ownerApproval,
    );
  }

  Future<AiAgentResponse> dispatch({
    required AgentContext context,
    required AgentTask task,
    required AiAgentRequest request,
    required AiAgent agent,
    AgentExecutionRequest? execution,
    ScopedGrant? grant,
    OwnerApproval? ownerApproval,
  }) async {
    final action = task.operation;
    final resource = task.resource;

    if (context.actorId.trim().isEmpty) {
      await _audit(
        context.actorId,
        action,
        resource,
        AuditOutcome.denied,
        'Missing actor identity.',
      );
      throw StateError('Missing actor identity.');
    }
    if (context.role == TofanPrincipalRole.owner &&
        !ownerAuthority.isOwner(context.actorId)) {
      await _audit(
        context.actorId,
        action,
        resource,
        AuditOutcome.denied,
        'Owner identity is not trusted by this gateway.',
      );
      throw StateError('Owner identity is not trusted by this gateway.');
    }

    if (request.role != agent.role) {
      await _audit(
        context.actorId,
        action,
        resource,
        AuditOutcome.denied,
        'Request role does not match target agent.',
      );
      throw ArgumentError('Request role does not match target agent.');
    }

    final agentAuthorization = policy.authorize(context: context, task: task);
    if (!agentAuthorization.allowed) {
      await _audit(
        context.actorId,
        action,
        resource,
        AuditOutcome.denied,
        agentAuthorization.reason,
      );
      throw StateError(agentAuthorization.reason);
    }

    if (grant != null) {
      final ownerDecision = ocAuth.authorize(
        actorId: context.actorId,
        operation: action,
        resourceId: resource,
        grant: grant,
        ownerApproval: ownerApproval,
      );
      if (!ownerDecision.allowed) {
        await _audit(
          context.actorId,
          action,
          resource,
          AuditOutcome.denied,
          ownerDecision.reason,
        );
        throw StateError(ownerDecision.reason);
      }
    }

    final requiresExecutionAuthorization =
        action.toLowerCase() == 'tool.execute' || execution != null;
    if (requiresExecutionAuthorization) {
      if (execution == null) {
        await _audit(
          context.actorId,
          action,
          resource,
          AuditOutcome.denied,
          'Tool and workspace authorization are required.',
        );
        throw StateError('Tool and workspace authorization are required.');
      }
      if (execution.authorization.actorId != context.actorId) {
        await _audit(
          context.actorId,
          action,
          resource,
          AuditOutcome.denied,
          'Tool authorization actor does not match agent context.',
        );
        throw StateError(
          'Tool authorization actor does not match agent context.',
        );
      }
      if (!executionCoordinator.authorize(
        toolId: execution.toolId,
        authorization: execution.authorization,
        workspaceRequest: execution.workspaceRequest,
      )) {
        await _audit(
          context.actorId,
          action,
          resource,
          AuditOutcome.denied,
          'Tool or workspace authorization denied.',
        );
        throw StateError('Tool or workspace authorization denied.');
      }
    }

    try {
      final response = await agent.handle(request);
      await _audit(
        context.actorId,
        action,
        resource,
        AuditOutcome.success,
        'Agent request completed.',
      );
      return response;
    } catch (error) {
      await _audit(
        context.actorId,
        action,
        resource,
        AuditOutcome.failure,
        'Agent request failed: $error',
      );
      rethrow;
    }
  }

  Future<void> _audit(
    String actorId,
    String action,
    String resourceId,
    AuditOutcome outcome,
    String reason,
  ) async {
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
      try {
        await auditRepository!.save(event);
      } catch (error, stackTrace) {
        developer.log(
          'Durable audit persistence failed for ${event.id}.',
          name: 'AgentGateway',
          error: error,
          stackTrace: stackTrace,
        );
        onAuditPersistenceFailure?.call(error, event);
      }
    }
  }
}
