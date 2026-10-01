import '../../domain/learning/analysis_models.dart';
import '../../domain/learning/learning_models.dart';

class AssessmentRemediationPlan {
  const AssessmentRemediationPlan({
    required this.assessmentId,
    required this.requiresRemediation,
    required this.reassessmentAllowed,
    required this.targets,
    required this.practiceFocus,
  });

  final String assessmentId;
  final bool requiresRemediation;
  final bool reassessmentAllowed;
  final List<String> targets;
  final List<String> practiceFocus;
}

class AssessmentRemediationEngine {
  const AssessmentRemediationEngine();

  AssessmentRemediationPlan plan({
    required AssessmentResult result,
    required LearningAnalysis analysis,
  }) {
    if (result.passed) {
      return AssessmentRemediationPlan(
        assessmentId: result.assessmentId,
        requiresRemediation: false,
        reassessmentAllowed: false,
        targets: const [],
        practiceFocus: const [],
      );
    }

    final targets = <String>{
      ...analysis.conceptGapIds,
      ...analysis.skillGapIds,
      ...analysis.remediationTargets,
    };

    if (targets.isEmpty) {
      targets.addAll(result.wrongQuestionIds);
    }

    final practiceFocus = <String>{
      ...analysis.conceptGapIds,
      ...analysis.learningOutcomeGapIds,
      ...analysis.skillGapIds,
    };

    return AssessmentRemediationPlan(
      assessmentId: result.assessmentId,
      requiresRemediation: true,
      reassessmentAllowed: true,
      targets: List.unmodifiable(targets),
      practiceFocus: List.unmodifiable(practiceFocus),
    );
  }
}
