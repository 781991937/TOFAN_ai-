import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/ai/agent_gateway.dart';
import 'package:tofan_ai/application/ai/agent_state.dart';
import 'package:tofan_ai/domain/security/agent_authorization_models.dart';
import 'package:tofan_ai/domain/security/audit_models.dart';
import 'package:tofan_ai/domain/security/audit_repository.dart';

class _FailingAuditRepository implements AuditRepository {
  @override
  Future<void> save(AuditEvent event) async {
    throw StateError('audit sink unavailable');
  }

  @override
  Future<List<AuditEvent>> load({String? actorId, String? resourceId}) async =>
      const [];
}

class _Agent implements AiAgent {
  @override
  AiAgentRole get role => AiAgentRole.academicTutor;

  @override
  Future<AiAgentResponse> handle(AiAgentRequest request) async =>
      AiAgentResponse(role: role, text: 'ok');
}

void main() {
  test(
    'audit persistence failure is observable without losing local event',
    () async {
      Object? observedError;
      AuditEvent? observedEvent;
      final recorder = AuditRecorder();
      final gateway = AgentGateway(
        auditRecorder: recorder,
        auditRepository: _FailingAuditRepository(),
        onAuditPersistenceFailure: (error, event) {
          observedError = error;
          observedEvent = event;
        },
      );

      await gateway.dispatch(
        context: const AgentContext(
          actorId: 'student-1',
          role: TofanPrincipalRole.student,
        ),
        task: const AgentTask(
          id: 'audit-1',
          agentRole: 'academicTutor',
          operation: 'read',
          resource: 'academic',
        ),
        request: const AiAgentRequest(
          role: AiAgentRole.academicTutor,
          request: 'اشرح',
        ),
        agent: _Agent(),
      );

      expect(observedError, isA<StateError>());
      expect(observedEvent, isNotNull);
      expect(recorder.events, hasLength(1));
      expect(recorder.events.single.outcome, AuditOutcome.success);
    },
  );
}
