import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/learning/analysis_models.dart';
import '../../domain/learning/learning_models.dart';
import 'assessment_analysis_engine.dart';
import 'assessment_remediation_engine.dart';
import 'skill_update_state.dart';

final assessmentResultProvider =
    NotifierProvider<AssessmentController, AssessmentResult?>(
  AssessmentController.new,
);

final assessmentHistoryProvider =
    NotifierProvider<AssessmentHistoryController, List<AssessmentAttempt>>(
  AssessmentHistoryController.new,
);

final learningAnalysisProvider =
    NotifierProvider<LearningAnalysisController, LearningAnalysis?>(
  LearningAnalysisController.new,
);

final assessmentRemediationProvider =
    NotifierProvider<AssessmentRemediationController, AssessmentRemediationPlan?>(
  AssessmentRemediationController.new,
);

class AssessmentController extends Notifier<AssessmentResult?> {
  @override
  AssessmentResult? build() => null;

  void submit({
    required String assessmentId,
    required int score,
    required int total,
    Map<String, bool> questionCorrect = const {},
  }) {
    final wrongQuestionIds = questionCorrect.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList(growable: false);
    final previousAttempts = ref
        .read(assessmentHistoryProvider)
        .where((attempt) => attempt.assessmentId == assessmentId)
        .toList(growable: false);
    final previousAttempt =
        previousAttempts.isEmpty ? null : previousAttempts.last;
    if (previousAttempt?.result.passed == true) return;

    final result = AssessmentResult(
      assessmentId: assessmentId,
      score: score.toDouble(),
      total: total.toDouble(),
      completedAt: DateTime.now(),
      wrongQuestionIds: wrongQuestionIds,
      attemptNumber: previousAttempts.length + 1,
      isReassessment: previousAttempt != null,
      previousAttemptId: previousAttempt?.attemptId,
    );
    state = result;
    ref.read(assessmentHistoryProvider.notifier).record(result);

    final analysis = ref.read(learningAnalysisProvider.notifier).analyze(result);
    ref.read(assessmentRemediationProvider.notifier).plan(
      result: result,
      analysis: analysis,
    );

    if (result.passed) {
      ref.read(skillUpdateHistoryProvider.notifier).apply(
        sourceId: result.attemptId,
        sourceType: result.isReassessment ? 'assessment_reassessment' : 'assessment',
        knowledgeDelta: analysis.knowledgeDelta,
        skillDelta: analysis.skillDelta,
        capabilityDelta: analysis.capabilityDelta,
      );
    }
  }

  void clear() {
    state = null;
    ref.read(learningAnalysisProvider.notifier).clear();
    ref.read(assessmentRemediationProvider.notifier).clear();
  }
}

class AssessmentHistoryController extends Notifier<List<AssessmentAttempt>> {
  @override
  List<AssessmentAttempt> build() => const [];

  void record(AssessmentResult result) {
    final attempt = AssessmentAttempt(
      attemptId: result.attemptId,
      assessmentId: result.assessmentId,
      attemptNumber: result.attemptNumber,
      result: result,
    );
    state = List.unmodifiable([...state, attempt]);
  }

  List<AssessmentAttempt> forAssessment(String assessmentId) =>
      state.where((attempt) => attempt.assessmentId == assessmentId).toList(
            growable: false,
          );

  void clear() => state = const [];
}

class LearningAnalysisController extends Notifier<LearningAnalysis?> {
  final AssessmentAnalysisEngine _engine = const AssessmentAnalysisEngine();

  @override
  LearningAnalysis? build() => null;

  LearningAnalysis analyze(AssessmentResult result) {
    final analysis = _engine.analyze(result);
    state = analysis;
    return analysis;
  }

  void clear() => state = null;
}

class AssessmentRemediationController
    extends Notifier<AssessmentRemediationPlan?> {
  final AssessmentRemediationEngine _engine =
      const AssessmentRemediationEngine();

  @override
  AssessmentRemediationPlan? build() => null;

  AssessmentRemediationPlan plan({
    required AssessmentResult result,
    required LearningAnalysis analysis,
  }) {
    final plan = _engine.plan(result: result, analysis: analysis);
    state = plan;
    return plan;
  }

  void clear() => state = null;
}
