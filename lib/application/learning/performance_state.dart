import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/learning/analysis_models.dart';
import '../../domain/learning/learning_models.dart';

final performanceProvider =
    NotifierProvider<PerformanceController, LearningAnalysis?>(
  PerformanceController.new,
);

class PerformanceController extends Notifier<LearningAnalysis?> {
  @override
  LearningAnalysis? build() => null;

  void evaluate(AssessmentResult result) {
    final p = result.percentage;
    final level = p < 60
        ? LearningPerformance.needsSupport
        : p < 70
            ? LearningPerformance.developing
            : p < 85
                ? LearningPerformance.proficient
                : LearningPerformance.advanced;

    state = LearningAnalysis(
      assessmentId: result.assessmentId,
      percentage: p,
      performance: level,
      knowledgeDelta: p < 60 ? 0 : p >= 85 ? 3 : 2,
      skillDelta: p < 60 ? 0 : p >= 85 ? 2 : 1,
      capabilityDelta: p < 60 ? 0 : p >= 85 ? 2 : 1,
      message: p < 60
          ? 'راجع الدرس ثم أعد التدريب.'
          : p < 70
              ? 'المستوى يتطور؛ واصل التدريب.'
              : p < 85
                  ? 'أداء جيد؛ انتقل تدريجيًا إلى التطبيق.'
                  : 'أداء متقدم؛ انتقل إلى تطبيقات أكثر تحديًا.',
    );
  }
}
