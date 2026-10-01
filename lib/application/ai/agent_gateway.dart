import '../../domain/security/agent_authorization_models.dart';
import 'agent_state.dart';

class AgentGateway {
  const AgentGateway({
    this.policy = const AgentPolicy(),
  });

  final AgentPolicy policy;

  Future<AiAgentResponse> dispatch({
    required AgentContext context,
    required AgentTask task,
    required AiAgentRequest request,
    required AiAgent agent,
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
    return agent.handle(request);
  }
}
