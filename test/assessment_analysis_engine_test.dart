import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/learning/assessment_analysis_engine.dart';
import 'package:tofan_ai/domain/learning/learning_models.dart';

void main() {
  test('failed questions become actionable learning analysis', () {
    const engine = AssessmentAnalysisEngine();
    final result = engine.analyze(
      AssessmentResult(
        assessmentId: 'python-1-assessment',
        score: 1,
        total: 3,
        completedAt: DateTime.utc(2026, 10, 1),
        wrongQuestionIds: const ['q-unknown'],
      ),
    );

    expect(result.performance, LearningPerformance.needsSupport);
    expect(result.errorQuestionIds, contains('q-unknown'));
    expect(result.errorAnalysis, isNotEmpty);
    expect(result.message, contains('فجوات'));
  });

  test('strong assessment produces positive skill delta', () {
    const engine = AssessmentAnalysisEngine();
    final result = engine.analyze(
      AssessmentResult(
        assessmentId: 'python-1-assessment',
        score: 9,
        total: 10,
        completedAt: DateTime.utc(2026, 10, 1),
      ),
    );

    expect(result.performance, LearningPerformance.advanced);
    expect(result.skillDelta, 2);
    expect(result.capabilityDelta, 2);
  });
}
