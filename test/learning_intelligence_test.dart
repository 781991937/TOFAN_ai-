import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/learning/learning_intelligence.dart';
import 'package:tofan_ai/domain/learning/student_learning_models.dart';

void main() {
  const engine = LearningIntelligenceEngine();

  test('detects missing concept and skill state', () {
    final report = engine.detectGaps(
      state: const StudentLearningState(),
      targetConceptIds: const ['concept-1'],
      targetSkillIds: const ['skill-1'],
      targetCourseIds: const [],
    );
    expect(report.conceptGapIds, contains('concept-1'));
    expect(report.skillGapIds, contains('skill-1'));
  });

  test('does not report sufficiently known concept or skill as a gap', () {
    final state = StudentLearningState(
      concepts: {'concept-1': ConceptState(conceptId: 'concept-1', knowledgeLevel: 80)},
      skills: {'skill-1': SkillState(skillId: 'skill-1', level: 80, status: StudentSkillStatus.acquired)},
    );
    final report = engine.detectGaps(
      state: state,
      targetConceptIds: const ['concept-1'],
      targetSkillIds: const ['skill-1'],
      targetCourseIds: const [],
    );
    expect(report.hasGaps, isFalse);
  });
}
