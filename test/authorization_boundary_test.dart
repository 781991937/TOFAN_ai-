import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';
import 'package:tofan_ai/domain/security/agent_authorization_models.dart';
import 'package:tofan_ai/domain/security/oc_auth_models.dart';

void main() {
  test('unknown agent operations are denied by default', () {
    final decision = const AgentPolicy().authorize(
      context: const AgentContext(
        actorId: 'student-1',
        role: TofanPrincipalRole.student,
      ),
      task: const AgentTask(
        id: 'unknown-1',
        agentRole: 'academicTutor',
        operation: 'future.delete.everything',
        resource: 'academic',
      ),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, contains('Unknown operation'));
  });

  test('student scope cannot be rebound to another actor', () {
    final decision = const AgentPolicy().authorize(
      context: const AgentContext(
        actorId: 'student-1',
        studentId: 'student-2',
        role: TofanPrincipalRole.student,
      ),
      task: const AgentTask(
        id: 'scope-1',
        agentRole: 'academicTutor',
        operation: 'read',
        resource: 'academic',
      ),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, contains('scope'));
  });

  test('unknown OCAuth operations are denied instead of becoming read', () {
    final grant = ScopedGrant(
      grantId: 'grant-1',
      ownerId: 'owner-1',
      subjectId: 'student-1',
      scope: OcAuthGrantScope.academic,
      resourceId: 'academic',
      permissions: const [ToolPermission.read],
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    final decision = const OcAuthPolicy().authorize(
      actorId: 'student-1',
      operation: 'unknown.operation',
      resourceId: 'academic',
      grant: grant,
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, contains('Unknown operation'));
  });

  test('owner approval must match the exact grant and subject', () {
    final grant = ScopedGrant(
      grantId: 'grant-1',
      ownerId: 'owner-1',
      subjectId: 'student-1',
      scope: OcAuthGrantScope.tool,
      resourceId: 'workspace-1',
      permissions: const [ToolPermission.execute],
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      requiresOwnerApproval: true,
    );

    final mismatched = OwnerApproval(
      approvalId: 'approval-1',
      ownerId: 'owner-1',
      grantId: 'grant-other',
      subjectId: 'student-1',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    final valid = OwnerApproval(
      approvalId: 'approval-2',
      ownerId: 'owner-1',
      grantId: 'grant-1',
      subjectId: 'student-1',
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    final policy = const OcAuthPolicy();
    expect(
      policy
          .authorize(
            actorId: 'student-1',
            operation: 'tool.execute',
            resourceId: 'workspace-1',
            grant: grant,
            ownerApproval: mismatched,
          )
          .allowed,
      isFalse,
    );
    expect(
      policy
          .authorize(
            actorId: 'student-1',
            operation: 'tool.execute',
            resourceId: 'workspace-1',
            grant: grant,
            ownerApproval: valid,
          )
          .allowed,
      isTrue,
    );
  });
}
