import '../../data/academic/academic_catalog.dart';
import '../../data/academic/academic_skill_capability_engine.dart';
import '../../domain/academic/academic_models.dart';
import '../../domain/learning/student_learning_models.dart';

class LearningGapReport {
  const LearningGapReport({required this.conceptGapIds, required this.skillGapIds, required this.prerequisiteCourseIds});
  final List<String> conceptGapIds;
  final List<String> skillGapIds;
  final List<String> prerequisiteCourseIds;
  bool get hasGaps => conceptGapIds.isNotEmpty || skillGapIds.isNotEmpty || prerequisiteCourseIds.isNotEmpty;
}

class LearningIntelligenceEngine {
  const LearningIntelligenceEngine({this.skillEngine = const AcademicSkillCapabilityEngine()});
  final AcademicSkillCapabilityEngine skillEngine;

  LearningGapReport detectGaps({
    required StudentLearningState state,
    required List<String> targetConceptIds,
    required List<String> targetSkillIds,
    required List<String> targetCourseIds,
  }) {
    final conceptGaps = targetConceptIds.where((id) {
      final item = state.concepts[id];
      return item == null || item.knowledgeLevel < 60;
    }).toSet();
    final skillGaps = targetSkillIds.where((id) {
      final item = state.skills[id];
      return item == null || item.level < 60 || item.status == StudentSkillStatus.missing;
    }).toSet();
    final prerequisiteGaps = <String>{};
    final courses = _allCourses();
    final byId = {for (final course in courses) course.id: course};
    for (final courseId in targetCourseIds) {
      final course = byId[courseId];
      if (course == null) continue;
      for (final prerequisite in course.prerequisiteCourseIds) {
        final prereq = byId[prerequisite];
        if (prereq == null) continue;
        final relevantConcepts = prereq.lessons.expand((lesson) => lesson.conceptIds).toSet();
        final known = relevantConcepts.every((id) => (state.concepts[id]?.knowledgeLevel ?? 0) >= 60);
        if (!known) prerequisiteGaps.add(prerequisite);
      }
    }
    return LearningGapReport(
      conceptGapIds: List.unmodifiable(conceptGaps),
      skillGapIds: List.unmodifiable(skillGaps),
      prerequisiteCourseIds: List.unmodifiable(prerequisiteGaps),
    );
  }

  List<AcademicCourse> _allCourses() {
    final result = <AcademicCourse>[...AcademicCatalog.foundationCourses];
    for (final university in AcademicCatalog.universities) {
      for (final college in university.colleges) {
        for (final specialization in college.specializations) {
          for (final year in specialization.years) {
            for (final semester in year.semesters) result.addAll(semester.courses);
          }
        }
      }
    }
    final unique = <String, AcademicCourse>{for (final course in result) course.id: course};
    return unique.values.toList(growable: false);
  }
}
