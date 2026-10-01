import '../../domain/academic/academic_models.dart';
import 'academic_catalog.dart';

/// Quality gate for future and existing courses using the canonical
/// Concept -> Learning Outcome -> Skill -> Evidence -> Capability contract.
class AcademicSkillCapabilityValidator {
  const AcademicSkillCapabilityValidator();

  List<String> validateCourse(AcademicCourse course) {
    final errors = <String>[];
    final skillIds = course.skills.map((s) => s.id).toSet();
    final outcomeIds = <String>{
      for (final lesson in course.lessons)
        ...lesson.learningOutcomeDefinitions.map((o) => o.id),
    };

    for (final skill in course.skills) {
      if (skill.id.trim().isEmpty) errors.add('skill id is empty');
      for (final outcomeId in skill.learningOutcomeIds) {
        if (!outcomeIds.contains(outcomeId)) {
          errors.add('skill ' + skill.id + ' references missing outcome ' + outcomeId);
        }
      }
      if (skill.evidenceRequirements.isEmpty) {
        errors.add('skill ' + skill.id + ' has no evidence requirements');
      }
    }

    for (final capability in course.capabilities) {
      if (capability.id.trim().isEmpty) errors.add('capability id is empty');
      for (final skillId in capability.requiredSkillIds) {
        if (!skillIds.contains(skillId)) {
          errors.add('capability ' + capability.id + ' references missing skill ' + skillId);
        }
      }
      if (capability.requiredSkillIds.isEmpty) {
        errors.add('capability ' + capability.id + ' has no required skills');
      }
      if (capability.evidenceRequirements.isEmpty) {
        errors.add('capability ' + capability.id + ' has no evidence requirements');
      }
    }

    return List.unmodifiable(errors);
  }

  List<String> validateCatalog() {
    final errors = <String>[];
    final courses = <AcademicCourse>[
      ...AcademicCatalog.foundationCourses,
      ...AcademicCatalog.universities.expand(
        (u) => u.colleges.expand(
          (c) => c.specializations.expand(
            (s) => s.years.expand(
              (y) => y.semesters.expand((semester) => semester.courses),
            ),
          ),
        ),
      ),
    ];
    final unique = <String, AcademicCourse>{};
    for (final course in courses) {
      unique[course.id] = course;
    }
    for (final course in unique.values) {
      errors.addAll(validateCourse(course).map((e) => course.id + ': ' + e));
    }
    return List.unmodifiable(errors);
  }
}
