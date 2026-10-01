import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/learning/assessment_analysis_engine.dart';
import 'package:tofan_ai/application/learning/assessment_remediation_engine.dart';
import 'package:tofan_ai/domain/learning/learning_models.dart';

void main() {
  const analysisEngine = AssessmentAnalysisEngine();
  const remediationEngine = AssessmentRemediationEngine();

  test('failed assessment creates actionable remediation and allows reassessment', () {
    final result = AssessmentResult(
      assessmentId: 'python-1-assessment',
      score: 1,
      total: 3,
      completedAt: DateTime.utc(2026, 10, 1),
      wrongQuestionIds: const ['q-unknown'],
    );
    final analysis = analysisEngine.analyze(result);
    final plan = remediationEngine.plan(result: result, analysis: analysis);

    expect(plan.requiresRemediation, isTrue);
    expect(plan.reassessmentAllowed, isTrue);
    expect(plan.targets, contains('q-unknown'));
  });

  test('passed assessment does not require remediation or reassessment', () {
    final result = AssessmentResult(
      assessmentId: 'python-1-assessment',
      score: 9,
      total: 10,
      completedAt: DateTime.utc(2026, 10, 1),
    );
    final analysis = analysisEngine.analyze(result);
    final plan = remediationEngine.plan(result: result, analysis: analysis);

    expect(plan.requiresRemediation, isFalse);
    expect(plan.reassessmentAllowed, isFalse);
    expect(plan.targets, isEmpty);
  });
}
