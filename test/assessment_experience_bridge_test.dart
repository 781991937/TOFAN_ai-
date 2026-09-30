import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/assessment_experience_bridge.dart';
import 'package:tofan_ai/abqari/experience_memory.dart';
import 'package:tofan_ai/domain/learning/learning_models.dart';

void main() {
  test('assessment results become experience with skill evidence', () {
    const bridge = AssessmentExperienceBridge();
    final result = AssessmentResult(
      assessmentId: 'python-1-assessment',
      score: 3,
      total: 3,
      completedAt: DateTime(2026, 9, 30),
    );
    final memory = bridge.record(
      memory: const AbqariExperienceMemory(),
      actorId: 'student-test',
      result: result,
    );
    expect(memory.entries, hasLength(1));
    expect(memory.entries.single.outcome, ExperienceOutcome.success);
    expect(memory.entries.single.learnedSkillIds, isNotEmpty);
  });
}
