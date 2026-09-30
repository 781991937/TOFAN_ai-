import '../data/academic/academic_catalog.dart';
import '../domain/learning/analysis_models.dart';
import '../domain/learning/learning_models.dart';
import 'experience_memory.dart';

class AssessmentExperienceBridge {
  const AssessmentExperienceBridge({this.analysisEngine = const AssessmentAnalysisEngine()});
  final AssessmentAnalysisEngine analysisEngine;

  AbqariExperienceMemory record({required AbqariExperienceMemory memory, required String actorId, required AssessmentResult result}) {
    final analysis = analysisEngine.analyze(result);
    final outcome = !result.passed
        ? ExperienceOutcome.failure
        : analysis.performance == LearningPerformance.advanced
            ? ExperienceOutcome.success
            : ExperienceOutcome.partial;
    return memory.record(AbqariExperience(
      id: 'assessment-' + result.assessmentId + '-' + result.completedAt.microsecondsSinceEpoch.toString(),
      actorId: actorId,
      task: result.assessmentId,
      outcome: outcome,
      observation: analysis.message,
      learnedSkillIds: _skillIds(result.assessmentId),
      createdAt: result.completedAt,
    ));
  }

  List<String> _skillIds(String assessmentId) {
    final ids = <String>{};
    for (final course in AcademicCatalog.referenceUniversity.colleges
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)) {
      for (final lesson in course.lessons) {
        for (final assessment in lesson.assessments) {
          if (assessment.id == assessmentId) {
            ids.addAll(lesson.skillIds);
            ids.addAll(assessment.questions.expand((question) => question.skillIds));
          }
        }
      }
    }
    return ids.toList(growable: false);
  }
}
