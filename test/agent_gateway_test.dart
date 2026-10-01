import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/application/ai/agent_gateway.dart';
import 'package:tofan_ai/application/ai/agent_state.dart';
import 'package:tofan_ai/domain/security/agent_authorization_models.dart';

class _FakeAgent implements AiAgent {
  @override
  AiAgentRole get role => AiAgentRole.academicTutor;

  @override
  Future<AiAgentResponse> handle(AiAgentRequest request) async =>
      AiAgentResponse(role: role, text: 'ok');
}

void main() {
  const gateway = AgentGateway();
  const agent = _FakeAgent();

  test('student may read academic content', () async {
    final response = await gateway.dispatch(
      context: const AgentContext(actorId: 'student-1', role: TofanPrincipalRole.student),
      task: const AgentTask(
        id: 't1',
        agentRole: 'academicTutor',
        operation: 'read',
        resource: 'academic',
      ),
      request: const AiAgentRequest(
        role: AiAgentRole.academicTutor,
        request: 'اشرح',
      ),
      agent: agent,
    );

    expect(response.text, 'ok');
  });

  test('student cannot execute tools', () {
    expect(
      () => gateway.dispatch(
        context: const AgentContext(actorId: 'student-1', role: TofanPrincipalRole.student),
        task: const AgentTask(
          id: 't2',
          agentRole: 'academicTutor',
          operation: 'tool.execute',
          resource: 'workspace',
        ),
        request: const AiAgentRequest(
          role: AiAgentRole.academicTutor,
          request: 'execute',
        ),
        agent: agent,
      ),
      throwsStateError,
    );
  });

  test('missing identity is denied', () {
    expect(
      () => gateway.dispatch(
        context: const AgentContext(actorId: '', role: TofanPrincipalRole.owner),
        task: const AgentTask(
          id: 't3',
          agentRole: 'academicTutor',
          operation: 'read',
          resource: 'academic',
        ),
        request: const AiAgentRequest(
          role: AiAgentRole.academicTutor,
          request: 'read',
        ),
        agent: agent,
      ),
      throwsStateError,
    );
  });
}
