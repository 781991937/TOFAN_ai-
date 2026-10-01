enum LearningPerformance { needsSupport, developing, proficient, advanced }

class LearningAnalysis {
  const LearningAnalysis({
    required this.assessmentId,
    required this.percentage,
    required this.performance,
    required this.knowledgeDelta,
    required this.skillDelta,
    required this.capabilityDelta,
    required this.message,
    this.errorQuestionIds = const [],
    this.errorAnalysis = const [],
    this.conceptGapIds = const [],
    this.learningOutcomeGapIds = const [],
    this.skillGapIds = const [],
    this.remediationTargets = const [],
  });

  final String assessmentId;
  final double percentage;
  final LearningPerformance performance;
  final double knowledgeDelta;
  final double skillDelta;
  final double capabilityDelta;
  final String message;
  final List<String> errorQuestionIds;
  final List<String> errorAnalysis;
  /// Academic identifiers implicated by incorrect answers.
  final List<String> conceptGapIds;
  final List<String> learningOutcomeGapIds;
  final List<String> skillGapIds;
  /// Human-readable remediation targets derived from explicit academic links.
  final List<String> remediationTargets;
}
