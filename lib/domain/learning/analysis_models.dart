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
  });

  final String assessmentId;
  final double percentage;
  final LearningPerformance performance;
  final double knowledgeDelta;
  final double skillDelta;
  final double capabilityDelta;
  final String message;
}
