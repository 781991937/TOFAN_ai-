import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/learning/assessment_state.dart';

void main() {
  test('assessment attempts are numbered and linked as reassessments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(assessmentResultProvider.notifier);

    controller.submit(
      assessmentId: 'assessment-1',
      score: 4,
      total: 10,
    );
    final first = container.read(assessmentResultProvider)!;

    controller.submit(
      assessmentId: 'assessment-1',
      score: 8,
      total: 10,
    );
    final second = container.read(assessmentResultProvider)!;

    expect(first.attemptNumber, 1);
    expect(first.isReassessment, isFalse);
    expect(second.attemptNumber, 2);
    expect(second.isReassessment, isTrue);
    expect(second.previousAttemptId, first.attemptId);
    expect(
      container.read(assessmentHistoryProvider),
      hasLength(2),
    );
  });
}
