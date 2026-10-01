import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_skill_capability_engine.dart';
import 'package:tofan_ai/domain/academic/academic_models.dart';

void main() {
  test('explicit concept to capability chain preserves every relationship', () {
    const outcome = AcademicLearningOutcome(
      id: 'outcome-python-vars',
      text: 'يكتب برنامجًا يستخدم المتغيرات.',
      conceptIds: ['concept-python-vars'],
    );
    const skill = AcademicSkill(
      id: 'skill-python-vars',
      name: 'استخدام المتغيرات',
      learningOutcomeIds: ['outcome-python-vars'],
      evidenceRequirements: ['برنامج يعمل ويطبع قيمة المتغير.'],
    );
    const capability = AcademicCapability(
      id: 'capability-python-vars',
      name: 'بناء برنامج صغير يستخدم المتغيرات',
      requiredSkillIds: ['skill-python-vars'],
      evidenceRequirements: ['تنفيذ البرنامج بنجاح.'],
    );

    expect(outcome.conceptIds, contains('concept-python-vars'));
    expect(skill.learningOutcomeIds, contains(outcome.id));
    expect(capability.requiredSkillIds, contains(skill.id));
    expect(skill.evidenceRequirements, isNotEmpty);
    expect(capability.evidenceRequirements, isNotEmpty);
  });

  test('engine does not fabricate chains from legacy ids alone', () {
    const engine = AcademicSkillCapabilityEngine();
    expect(engine.chainsForConcept('concept-python-1'), isEmpty);
  });
}
