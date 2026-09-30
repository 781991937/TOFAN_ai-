class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.text,
    required this.dimension,
  });

  final String id;
  final String text;
  final DiagnosticDimension dimension;
}

enum DiagnosticDimension {
  knowledge,
  skill,
  capability,
}

class DiagnosticResult {
  const DiagnosticResult({
    required this.answers,
    required this.knowledgeLevel,
    required this.skillLevel,
    required this.capabilityLevel,
  });

  final Map<String, int> answers;
  final double knowledgeLevel;
  final double skillLevel;
  final double capabilityLevel;
}
