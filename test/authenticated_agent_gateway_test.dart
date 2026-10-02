import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/application/ai/agent_gateway.dart';
import 'package:tofan_ai/application/ai/agent_state.dart';
import 'package:tofan_ai/domain/security/agent_authorization_models.dart';
import 'package:tofan_ai/domain/security/authentication_models.dart';

class _FakeAuth implements AuthenticationGateway {
  _FakeAuth(this.session);

  final AuthenticationSession? session;

  @override
  Future<AuthenticationSession?> authenticate({required String credential}) async =>
      session;

  @override
  Future<AuthenticationSession?> currentSession() async => session;

  @override
  Future<void> signOut(String sessionId) async {}
}

class _FakeAgent implements AiAgent {
  @override
  AiAgentRole get role => AiAgentRole.academicTutor;

  String? seenRequest;

  @override
  Future<AiAgentResponse> handle(AiAgentRequest request) async {
    seenRequest = request.request;
    return AiAgentResponse(role: role, text: 'ok');
  }
}

void main() {
  test('authenticated dispatch derives actor from trusted session', () async {
    final agent = _FakeAgent();
    final gateway = AgentGateway();
    final auth = _FakeAuth(
      AuthenticationSession(
        identity: AuthenticatedIdentity(
          actorId: 'user-123',
          email: 'profile@example.com',
          role: 'student',
          authenticatedAt: DateTime.now(),
        ),
        status: AuthenticationStatus.authenticated,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );

    final response = await gateway.dispatchAuthenticated(
      authentication: auth,
      task: const AgentTask(
        id: 't1',
        agentRole: 'academicTutor',
        operation: 'read',
        resource: 'academic',
      ),
      request: const AiAgentRequest(
        role: AiAgentRole.academicTutor,
        request: 'explain',
      ),
      agent: agent,
    );

    expect(response.text, 'ok');
    expect(agent.seenRequest, 'explain');
  });

  test('authenticated dispatch rejects missing session', () async {
    final gateway = AgentGateway();
    final auth = _FakeAuth(null);

    expect(
      () => gateway.dispatchAuthenticated(
        authentication: auth,
        task: const AgentTask(
          id: 't1',
          agentRole: 'academicTutor',
          operation: 'read',
          resource: 'academic',
        ),
        request: const AiAgentRequest(
          role: AiAgentRole.academicTutor,
          request: 'explain',
        ),
        agent: _FakeAgent(),
      ),
      throwsStateError,
    );
  });
}
