import '../../domain/academic/academic_models.dart';
import 'academic_catalog.dart';

/// Canonical mapping engine for:
/// Concept -> Learning Outcome -> Skill -> Evidence -> Capability.
///
/// It only reads explicit academic definitions from the canonical catalog.
/// It never infers a capability from a project, score, or skill id.
class AcademicSkillCapabilityEngine {
  const AcademicSkillCapabilityEngine();

  List<AcademicLearningOutcome> outcomesForConcept(String conceptId) {
    return _allLessons()
        .expand((lesson) => lesson.learningOutcomeDefinitions)
        .where((outcome) => outcome.conceptIds.contains(conceptId))
        .toList(growable: false);
  }

  List<AcademicSkill> skillsForOutcome(String outcomeId) {
    return _allCourses()
        .expand((course) => course.skills)
        .where((skill) => skill.learningOutcomeIds.contains(outcomeId))
        .toList(growable: false);
  }

  List<AcademicCapability> capabilitiesForSkill(String skillId) {
    return _allCourses()
        .expand((course) => course.capabilities)
        .where((capability) => capability.requiredSkillIds.contains(skillId))
        .toList(growable: false);
  }

  List<String> evidenceForSkill(String skillId) {
    final evidence = <String>{};
    for (final course in _allCourses()) {
      for (final skill in course.skills.where((item) => item.id == skillId)) {
        evidence.addAll(skill.evidenceRequirements);
      }
      for (final lesson in course.lessons) {
        if (lesson.skillIds.contains(skillId)) {
          evidence.addAll(lesson.skillEvidence);
        }
      }
    }
    return evidence.toList(growable: false);
  }

  /// Returns only complete explicit chains present in canonical definitions.
  List<AcademicCapabilityChain> chainsForConcept(String conceptId) {
    final chains = <AcademicCapabilityChain>[];
    for (final outcome in outcomesForConcept(conceptId)) {
      for (final skill in skillsForOutcome(outcome.id)) {
        for (final capability in capabilitiesForSkill(skill.id)) {
          chains.add(
            AcademicCapabilityChain(
              concept: conceptId,
              outcome: outcome,
              skill: skill,
              evidence: evidenceForSkill(skill.id),
              capability: capability,
            ),
          );
        }
      }
    }
    return List.unmodifiable(chains);
  }

  List<AcademicCourse> _allCourses() {
    final courses = <AcademicCourse>[];
    courses.addAll(AcademicCatalog.foundationCourses);
    for (final university in AcademicCatalog.universities) {
      for (final college in university.colleges) {
        for (final specialization in college.specializations) {
          for (final year in specialization.years) {
            for (final semester in year.semesters) {
              courses.addAll(semester.courses);
            }
          }
        }
      }
    }
    final unique = <String, AcademicCourse>{};
    for (final course in courses) {
      unique[course.id] = course;
    }
    return unique.values.toList(growable: false);
  }

  Iterable<AcademicLesson> _allLessons() sync* {
    for (final course in _allCourses()) {
      for (final lesson in course.lessons) {
        yield lesson;
      }
    }
  }
}

class AcademicCapabilityChain {
  const AcademicCapabilityChain({
    required this.concept,
    required this.outcome,
    required this.skill,
    required this.evidence,
    required this.capability,
  });

  final String concept;
  final AcademicLearningOutcome outcome;
  final AcademicSkill skill;
  final List<String> evidence;
  final AcademicCapability capability;
}
