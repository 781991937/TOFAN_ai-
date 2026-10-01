import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/execution/correction_loop.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';

void main() {
  test('correction loop classifies failure and preserves re-test evidence', () {
    const loop = CorrectionLoop();
    final correction = loop.plan(
      affectedComponent: 'tool.registry',
      error: 'test assertion failed',
    );

    final trace = loop.recordRetest(
      task: 'tool authorization',
      plan: const ['authorize', 'test'],
      outcome: ExecutionOutcome.success,
      correction: correction,
      tests: const [
        TestEvidence(
          testId: 'tool-auth-1',
          skillId: 'security-tool-use',
          passed: true,
          observation: 'scoped resource accepted',
        ),
      ],
      evidence: const ['previous failure retained'],
    );

    expect(correction.errorClass, ErrorClass.test);
    expect(trace.corrections, hasLength(1));
    expect(trace.tests.single.passed, isTrue);
    expect(trace.evidence, contains('previous failure retained'));
    expect(trace.errors, isEmpty);
  });
}
