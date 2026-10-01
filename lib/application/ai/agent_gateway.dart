import '../../domain/execution/execution_models.dart';
import '../../domain/security/agent_authorization_models.dart';
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
  const AgentGateway({
    this.policy = const AgentPolicy(),
    this.executionCoordinator = const AbqariExecutionCoordinator(),
  });

  final AgentPolicy policy;
  final AbqariExecutionCoordinator executionCoordinator;

  Future<AiAgentResponse> dispatch({
    required AgentContext context,
    required AgentTask task,
    required AiAgentRequest request,
    required AiAgent agent,
    AgentExecutionRequest? execution,
  }) async {
    final authorization = policy.authorize(context: context, task: task);
    if (!authorization.allowed) {
      throw StateError(authorization.reason);
    }
    if (context.actorId.trim().isEmpty) {
      throw StateError('Missing actor identity.');
    }
    if (request.role != agent.role) {
      throw ArgumentError('Request role does not match target agent.');
    }

    final requiresExecutionAuthorization =
        task.operation.toLowerCase() == 'tool.execute' || execution != null;
    if (requiresExecutionAuthorization) {
      if (execution == null) {
        throw StateError('Tool and workspace authorization are required.');
      }
      if (execution.authorization.actorId != context.actorId) {
        throw StateError('Tool authorization actor does not match agent context.');
      }
      if (!executionCoordinator.authorize(
        toolId: execution.toolId,
        authorization: execution.authorization,
        workspaceRequest: execution.workspaceRequest,
      )) {
        throw StateError('Tool or workspace authorization denied.');
      }
    }

    return agent.handle(request);
  }
}
