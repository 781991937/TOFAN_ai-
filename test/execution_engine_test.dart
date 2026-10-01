import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';
import 'package:tofan_ai/application/execution/execution_engine.dart';

void main() {
  const engine = ExecutionEngine();

  test('workspace policy denies commands outside the allowlist', () {
    const policy = WorkspacePolicy(allowedCommands: ['python'], blockedCommands: ['python -c']);
    expect(policy.allowsCommand('python main.py'), isTrue);
    expect(policy.allowsCommand('python -c print(1)'), isFalse);
    expect(policy.allowsCommand('bash main.sh'), isFalse);
  });

  test('tool authorization is deny by default when scope or permission is absent', () {
    const tool = ToolContract(
      id: 'code.test',
      operation: 'test',
      resource: 'workspace:student-1',
      permissions: [ToolPermission.execute],
    );
    const denied = ToolAuthorization(actorId: 'student-1');
    const allowed = ToolAuthorization(
      actorId: 'student-1',
      permissions: [ToolPermission.execute],
      resourceScope: ['workspace:student-1'],
    );
    expect(engine.authorizeTool(tool: tool, authorization: denied), isFalse);
    expect(engine.authorizeTool(tool: tool, authorization: allowed), isTrue);
  });

  test('capability is not verified without required skill evidence', () {
    final result = engine.verifyCapability(
      capabilityId: 'cap-1',
      requiredSkillIds: ['skill-1', 'skill-2'],
      evidence: const [TestEvidence(testId: 'test-1', passed: true, observation: 'ok')],
    );
    expect(result.verified, isFalse);
  });

  test('capability verification requires successful evidence', () {
    final result = engine.verifyCapability(
      capabilityId: 'cap-1',
      requiredSkillIds: ['skill-1', 'skill-2'],
      evidence: const [
        TestEvidence(testId: 'test-1', passed: true, observation: 'ok'),
        TestEvidence(testId: 'test-2', passed: true, observation: 'ok'),
      ],
    );
    expect(result.verified, isTrue);
  });
}
