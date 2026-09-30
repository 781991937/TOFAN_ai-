import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/learning/analysis_models.dart';
import '../../domain/learning/learning_models.dart';
import 'skill_update_state.dart';

final assessmentResultProvider =
    NotifierProvider<AssessmentController, AssessmentResult?>(
  AssessmentController.new,
);

final learningAnalysisProvider =
    NotifierProvider<LearningAnalysisController, LearningAnalysis?>(
  LearningAnalysisController.new,
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
    final result = AssessmentResult(
      assessmentId: assessmentId,
      score: score.toDouble(),
      total: total.toDouble(),
      completedAt: DateTime.now(),
      wrongQuestionIds: wrongQuestionIds,
    );
    state = result;

    final analysis = ref.read(learningAnalysisProvider.notifier).analyze(result);
    if (result.passed) {
      ref.read(skillUpdateHistoryProvider.notifier).apply(
        sourceId: result.assessmentId,
        sourceType: 'assessment',
        knowledgeDelta: analysis.knowledgeDelta,
        skillDelta: analysis.skillDelta,
        capabilityDelta: analysis.capabilityDelta,
      );
    }
  }

  void clear() => state = null;
}

class LearningAnalysisController extends Notifier<LearningAnalysis?> {
  @override
  LearningAnalysis? build() => null;

  LearningAnalysis analyze(AssessmentResult result) {
    final p = result.percentage;
    final performance = p < 60
        ? LearningPerformance.needsSupport
        : p < 70
            ? LearningPerformance.developing
            : p < 85
                ? LearningPerformance.proficient
                : LearningPerformance.advanced;

    final errorAnalysis = result.wrongQuestionIds.isEmpty
        ? const <String>[]
        : result.wrongQuestionIds
            .map((id) => 'مراجعة السؤال «$id»: أعد قراءة المفهوم المرتبط به، ثم حل مثالًا جديدًا قبل إعادة التقييم.')
            .toList(growable: false);

    final analysis = LearningAnalysis(
      assessmentId: result.assessmentId,
      percentage: p,
      performance: performance,
      knowledgeDelta: p < 60 ? 0 : p >= 85 ? 3 : 2,
      skillDelta: p < 60 ? 0 : p >= 85 ? 2 : 1,
      capabilityDelta: p < 60 ? 0 : p >= 85 ? 2 : 1,
      errorQuestionIds: result.wrongQuestionIds,
      errorAnalysis: errorAnalysis,
      message: p < 60
          ? 'راجع الدرس ثم أعد التدريب.'
          : p < 70
              ? 'المستوى يتطور؛ واصل التدريب.'
              : p < 85
                  ? 'أداء جيد؛ انتقل تدريجيًا إلى التطبيق.'
                  : 'أداء متقدم؛ انتقل إلى تطبيقات أكثر تحديًا.',
    );
    state = analysis;
    return analysis;
  }
}
