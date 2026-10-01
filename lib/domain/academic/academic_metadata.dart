/// Academic metadata used by the global TOFAN library.
/// Separates curriculum metadata and provenance from lesson text.
enum AcademicPublicationStatus {
  draft,
  privateContent,
  pendingReview,
  validated,
  published,
  deprecated,
}

enum AcademicCourseComplexity {
  foundation,
  core,
  advanced,
  capstone,
}

class AcademicSourceReference {
  const AcademicSourceReference({
    required this.id,
    required this.title,
    required this.publisher,
    required this.kind,
    this.url,
    this.version,
  });

  final String id;
  final String title;
  final String publisher;
  final String kind;
  final String? url;
  final String? version;
}

class AcademicContentProvenance {
  const AcademicContentProvenance({
    this.status = AcademicPublicationStatus.draft,
    this.sourceReferences = const [],
    this.author = 'TOFAN',
    this.reviewer,
    this.version = '0.1.0',
  });

  final AcademicPublicationStatus status;
  final List<AcademicSourceReference> sourceReferences;
  final String author;
  final String? reviewer;
  final String version;

  bool get hasSource => sourceReferences.isNotEmpty;
  bool get isReviewable =>
      status == AcademicPublicationStatus.pendingReview ||
      status == AcademicPublicationStatus.validated ||
      status == AcademicPublicationStatus.published;
}

class AcademicCourseProfile {
  const AcademicCourseProfile({
    required this.credits,
    required this.contactHours,
    this.practicalHours = 0,
    required this.complexity,
  });

  final double credits;
  final double contactHours;
  final double practicalHours;
  final AcademicCourseComplexity complexity;

  bool get isValid =>
      credits > 0 && contactHours > 0 && practicalHours >= 0 &&
      contactHours >= practicalHours;
}
