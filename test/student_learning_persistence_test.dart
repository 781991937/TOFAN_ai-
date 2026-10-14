import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/student/student_state.dart';
import 'package:tofan_ai/domain/learning/student_learning_models.dart';
import 'package:tofan_ai/domain/learning/student_learning_repository.dart';
import 'package:tofan_ai/domain/security/authentication_models.dart';
import 'package:tofan_ai/providers/security_provider.dart';

class _FakeAuthentication implements AuthenticationGateway {
  _FakeAuthentication(this.session);

  final AuthenticationSession? session;

  @override
  Future<AuthenticationSession?> authenticate({
    required String credential,
  }) async => session;

  @override
  Future<AuthenticationSession?> currentSession() async => session;

  @override
  Future<void> signOut(String sessionId) async {}
}

class _MemoryRepository implements StudentLearningRepository {
  StudentLearningState? stored;
  String? savedStudentId;
  String? clearedStudentId;

  @override
  Future<void> save(String studentId, StudentLearningState state) async {
    savedStudentId = studentId;
    stored = state;
  }

  @override
  Future<StudentLearningState?> load(String studentId) async =>
      savedStudentId == studentId ? stored : null;

  @override
  Future<void> clear(String studentId) async {
    clearedStudentId = studentId;
    stored = null;
  }
}

void main() {
  test(
    'student learning state survives save and reload, then clears permanently',
    () async {
      final repository = _MemoryRepository();
      final session = AuthenticationSession(
        identity: AuthenticatedIdentity(
          actorId: 'student-1',
          email: 'student@example.com',
          role: 'student',
          authenticatedAt: DateTime.now(),
        ),
        status: AuthenticationStatus.authenticated,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final container = ProviderContainer(
        overrides: [
          authenticationGatewayProvider.overrideWithValue(
            _FakeAuthentication(session),
          ),
          studentLearningRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(studentLearningStateProvider.notifier);
      await controller.reload();
      controller.recordKnowledge(
        sourceId: 'assessment-1',
        sourceType: 'assessment',
        conceptIds: const ['concept-1'],
        skillIds: const ['skill-1'],
        capabilityIds: const ['capability-1'],
        knowledgeLevel: 35,
        skillLevel: 65,
      );
      await controller.save();

      expect(repository.savedStudentId, 'student-1');
      expect(repository.stored?.concepts['concept-1']?.knowledgeLevel, 35);
      expect(
        repository.stored?.skills['skill-1']?.status,
        StudentSkillStatus.developing,
      );
      expect(repository.stored?.history.single.sourceId, 'assessment-1');

      final reloadedContainer = ProviderContainer(
        overrides: [
          authenticationGatewayProvider.overrideWithValue(
            _FakeAuthentication(session),
          ),
          studentLearningRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(reloadedContainer.dispose);
      final reloaded = reloadedContainer.read(
        studentLearningStateProvider.notifier,
      );
      await reloaded.reload();

      expect(reloaded.state.concepts['concept-1']?.knowledgeLevel, 35);
      expect(reloaded.state.skills['skill-1']?.level, 65);
      expect(reloaded.state.history.single.sourceType, 'assessment');

      await reloaded.clear();
      expect(repository.clearedStudentId, 'student-1');
      expect(repository.stored, isNull);
      expect(reloaded.state, const StudentLearningState());
    },
  );
}
