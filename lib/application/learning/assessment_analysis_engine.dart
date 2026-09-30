import '../../data/academic/academic_catalog.dart';
import '../../domain/academic/academic_models.dart';
import '../../domain/learning/analysis_models.dart';
import '../../domain/learning/learning_models.dart';

class AssessmentAnalysisEngine {
  const AssessmentAnalysisEngine();

  LearningAnalysis analyze(AssessmentResult result) {
    final context = _questionContext(result.assessmentId);
    final errors = <String>[];

    for (final questionId in result.wrongQuestionIds) {
      final question = context[questionId];
      if (question == null) {
        errors.add('السؤال $questionId يحتاج إلى مراجعة سياقه الأكاديمي.');
        continue;
      }
      final concepts = question.conceptIds.isEmpty
          ? 'مفهوم مرتبط بالسؤال'
          : question.conceptIds.join('، ');
      final skills = question.skillIds.isEmpty
          ? 'مهارة مرتبطة بالسؤال'
          : question.skillIds.join('، ');
      errors.add(
        'السؤال $questionId: راجع المفاهيم ($concepts) وتدرب على المهارات ($skills).',
      );
    }

    final percentage = result.percentage;
    final performance = percentage < 60
        ? LearningPerformance.needsSupport
        : percentage < 70
            ? LearningPerformance.developing
            : percentage < 85
                ? LearningPerformance.proficient
                : LearningPerformance.advanced;

    return LearningAnalysis(
      assessmentId: result.assessmentId,
      percentage: percentage,
      performance: performance,
      knowledgeDelta: percentage < 60 ? 0 : percentage >= 85 ? 3 : 2,
      skillDelta: percentage < 60 ? 0 : percentage >= 85 ? 2 : 1,
      capabilityDelta: percentage < 60 ? 0 : percentage >= 85 ? 2 : 1,
      errorQuestionIds: result.wrongQuestionIds,
      errorAnalysis: List.unmodifiable(errors),
      message: percentage < 60
          ? 'توجد فجوات تحتاج إلى مراجعة وتدريب قبل إعادة التقييم.'
          : percentage < 70
              ? 'المعرفة تتطور؛ ركز على المفاهيم المرتبطة بالأخطاء.'
              : percentage < 85
                  ? 'أداء جيد؛ عزز المهارات بالتطبيق.'
                  : 'أداء متقدم؛ انتقل إلى تطبيقات أكثر تحديًا.',
    );
  }

  Map<String, AssessmentQuestion> _questionContext(String assessmentId) {
    final result = <String, AssessmentQuestion>{};
    for (final college in AcademicCatalog.referenceUniversity.colleges) {
      for (final specialization in college.specializations) {
        for (final year in specialization.years) {
          for (final semester in year.semesters) {
            for (final course in semester.courses) {
              for (final lesson in course.lessons) {
                for (final assessment in lesson.assessments) {
                  if (assessment.id != assessmentId) continue;
                  for (final question in assessment.questions) {
                    result[question.id] = question;
                  }
                }
              }
            }
          }
        }
      }
    }
    return result;
  }
}
