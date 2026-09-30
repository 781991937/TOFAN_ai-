import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/learning/learning_models.dart';
import '../student/student_state.dart';

final assessmentResultProvider =
    NotifierProvider<AssessmentController, AssessmentResult?>(
  AssessmentController.new,
);

class AssessmentController extends Notifier<AssessmentResult?> {
  @override
  AssessmentResult? build() => null;

  void submit({
    required String assessmentId,
    required int score,
    required int total,
  }) {
    final result = AssessmentResult(
      assessmentId: assessmentId,
      score: score.toDouble(),
      total: total.toDouble(),
      completedAt: DateTime.now(),
    );
    state = result;

    if (result.passed) {
      ref.read(smartStudentProvider.notifier).recordLearning(
        knowledgeDelta: result.percentage >= 80 ? 3 : 2,
        skillDelta: result.percentage >= 80 ? 2 : 1,
        capabilityDelta: result.percentage >= 80 ? 2 : 1,
      );
    }
  }

  void clear() => state = null;
}
