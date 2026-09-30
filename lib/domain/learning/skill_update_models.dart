class SkillUpdateRecord {
  const SkillUpdateRecord({
    required this.sourceId,
    required this.sourceType,
    required this.knowledgeDelta,
    required this.skillDelta,
    required this.capabilityDelta,
    required this.appliedAt,
  });

  final String sourceId;
  final String sourceType;
  final double knowledgeDelta;
  final double skillDelta;
  final double capabilityDelta;
  final DateTime appliedAt;
}
