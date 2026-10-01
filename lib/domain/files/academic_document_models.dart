class AcademicDocument {
  const AcademicDocument({
    required this.id,
    required this.name,
    required this.content,
    this.mimeType = 'text/plain',
    this.sourceReference,
  });

  final String id;
  final String name;
  final String content;
  final String mimeType;
  final String? sourceReference;
}

class AcademicDocumentMatch {
  const AcademicDocumentMatch({
    required this.documentId,
    required this.targetType,
    required this.targetId,
    required this.confidence,
    required this.evidence,
  });

  final String documentId;
  final AcademicDocumentTargetType targetType;
  final String targetId;
  final double confidence;
  final String evidence;
}

enum AcademicDocumentTargetType {
  course,
  knowledgeUnit,
  lesson,
  concept,
  skill,
}

class AcademicDocumentMapping {
  const AcademicDocumentMapping({
    required this.documentId,
    required this.matches,
  });

  final String documentId;
  final List<AcademicDocumentMatch> matches;

  List<AcademicDocumentMatch> forType(AcademicDocumentTargetType type) =>
      List.unmodifiable(matches.where((match) => match.targetType == type));
}
