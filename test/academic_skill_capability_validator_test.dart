import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_skill_capability_validator.dart';
import 'package:tofan_ai/domain/academic/academic_models.dart';

void main() {
  test('future course contract accepts a complete explicit chain', () {
    const outcome = AcademicLearningOutcome(
      id: 'outcome-1',
      text: 'يطبق المهارة.',
      conceptIds: ['concept-1'],
    );
    const skill = AcademicSkill(
      id: 'skill-1',
      name: 'مهارة تطبيقية',
      learningOutcomeIds: ['outcome-1'],
      evidenceRequirements: ['حل عملي قابل للفحص'],
    );
    const capability = AcademicCapability(
      id: 'capability-1',
      name: 'تنفيذ مهمة مستقلة',
      requiredSkillIds: ['skill-1'],
      evidenceRequirements: ['نتيجة تنفيذ موثقة'],
    );
    const course = AcademicCourse(
      id: 'future-course',
      name: 'مقرر مستقبلي',
      lessons: [
        AcademicLesson(
          id: 'future-lesson',
          title: 'درس مستقبلي',
          learningOutcomeDefinitions: [outcome],
        ),
      ],
      skills: [skill],
      capabilities: [capability],
    );

    expect(const AcademicSkillCapabilityValidator().validateCourse(course), isEmpty);
  });

  test('future course contract rejects broken references and missing evidence', () {
    const course = AcademicCourse(
      id: 'invalid-course',
      name: 'مقرر غير مكتمل',
      lessons: [],
      skills: [
        AcademicSkill(id: 'skill-x', name: 'Skill', learningOutcomeIds: ['missing']),
      ],
      capabilities: [
        AcademicCapability(
          id: 'cap-x',
          name: 'Capability',
          requiredSkillIds: ['missing-skill'],
        ),
      ],
    );

    final errors = const AcademicSkillCapabilityValidator().validateCourse(course);
    expect(errors, contains('skill skill-x references missing outcome missing'));
    expect(errors, contains('skill skill-x has no evidence requirements'));
    expect(errors, contains('capability cap-x references missing skill missing-skill'));
    expect(errors, contains('capability cap-x has no evidence requirements'));
  });
}
