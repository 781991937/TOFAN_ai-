import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/learning/skill_update_models.dart';
import '../student/student_state.dart';

final skillUpdateHistoryProvider =
    NotifierProvider<SkillUpdateController, List<SkillUpdateRecord>>(
  SkillUpdateController.new,
);

class SkillUpdateController extends Notifier<List<SkillUpdateRecord>> {
  @override
  List<SkillUpdateRecord> build() => const [];

  void apply({
    required String sourceId,
    required String sourceType,
    required double knowledgeDelta,
    required double skillDelta,
    required double capabilityDelta,
  }) {
    if (state.any((record) =>
        record.sourceId == sourceId && record.sourceType == sourceType)) {
      return;
    }

    final record = SkillUpdateRecord(
      sourceId: sourceId,
      sourceType: sourceType,
      knowledgeDelta: knowledgeDelta,
      skillDelta: skillDelta,
      capabilityDelta: capabilityDelta,
      appliedAt: DateTime.now(),
    );

    state = [...state, record];

    ref.read(smartStudentProvider.notifier).recordLearning(
      knowledgeDelta: knowledgeDelta,
      skillDelta: skillDelta,
      capabilityDelta: capabilityDelta,
    );
  }

  void clear() => state = const [];
}
