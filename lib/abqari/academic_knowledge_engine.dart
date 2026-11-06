import '../data/academic/academic_catalog.dart';
import '../data/academic/academic_knowledge_unit_catalog.dart';
import '../data/academic/academic_library_security_catalog.dart';
import 'abqari_models.dart';

class AcademicKnowledgeEngine {
  const AcademicKnowledgeEngine();

  List<AbqariKnowledgeItem> search(String query) =>
      _search(query, allowedAreaIds: null, limit: 20);

  /// Searches one canonical security domain. Scope filtering is performed
  /// against the complete candidate set before ranking and result truncation.
  List<AbqariKnowledgeItem> searchInDomain(
    String query, {
    required String domainId,
    int limit = 20,
  }) {
    final domain = AcademicLibrarySecurityCatalog.domains
        .where((item) => item.id == domainId)
        .firstOrNull;
    if (domain == null) return const [];
    if (limit < 1 || limit > 20) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 20.');
    }
    return _search(
      query,
      allowedAreaIds: domain.knowledgeAreaIds.toSet(),
      limit: limit,
    );
  }

  List<AbqariKnowledgeItem> _search(
    String query, {
    required Set<String>? allowedAreaIds,
    required int limit,
  }) {
    final tokens = _tokens(query);
    final results = <AbqariKnowledgeItem>[];
    for (final field in AcademicCatalog.fields) {
      for (final university in field.universities) {
        for (final college in university.colleges) {
          for (final specialization in college.specializations) {
            for (final year in specialization.years) {
              for (final semester in year.semesters) {
                for (final course in semester.courses) {
                  for (final unit in course.normalizedUnits) {
                    for (final lesson in unit.lessons) {
                      final canonicalUnits = AcademicKnowledgeUnitCatalog.forCourse(course);
                      final canonicalUnitText = canonicalUnits.map((item) => '${item.name} ${item.arabicName} ${item.description}').join(' ');
                      final haystack = <String>[field.name, university.name, college.name, specialization.name, course.name, unit.title, canonicalUnitText, lesson.title, lesson.definition, lesson.content, ...lesson.applications, ...lesson.keyTerms, ...lesson.learningOutcomes].join(' ').toLowerCase();
                      if (tokens.any(haystack.contains)) {
                        results.add(AbqariKnowledgeItem(
                          id: lesson.id,
                          title: lesson.title,
                          sourcePath: 'field/${field.id}/university/${university.id}/college/${college.id}/specialization/${specialization.id}/year/${year.number}/semester/${semester.number}/course/${course.id}/unit/${unit.id}',
                          content: lesson.content,
                          definition: lesson.definition,
                          applications: lesson.applications,
                          learningOutcomes: lesson.learningOutcomes,
                          terms: lesson.keyTerms,
                          conceptIds: lesson.conceptIds,
                          skillIds: lesson.skillIds,
                          knowledgeAreaIds: course.knowledgeAreaIds,
                          knowledgeUnitIds: course.knowledgeUnitIds,
                          courseId: course.id,
                          unitId: unit.id,
                          lessonId: lesson.id,
                          projectTitles: <String>{
                            ...lesson.projects.map((p) => p.title),
                            ...course.projects.map((p) => p.title),
                          }.toList(growable: false),
                        ));
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    // Shared foundations are canonical library content referenced by every
    // specialization; they are indexed once rather than copied into curricula.
    for (final course in AcademicCatalog.foundationCourses) {
      for (final unit in course.normalizedUnits) {
        for (final lesson in unit.lessons) {
          final canonicalUnits = AcademicKnowledgeUnitCatalog.forCourse(course);
          final canonicalUnitText = canonicalUnits
              .map((item) => '${item.name} ${item.arabicName} ${item.description}')
              .join(' ');
          final haystack = <String>[
            'الأساسيات المشتركة',
            course.name,
            unit.title,
            canonicalUnitText,
            lesson.title,
            lesson.definition,
            lesson.content,
            ...lesson.applications,
            ...lesson.keyTerms,
            ...lesson.learningOutcomes,
          ].join(' ').toLowerCase();
          if (!tokens.any(haystack.contains)) continue;
          results.add(
            AbqariKnowledgeItem(
              id: lesson.id,
              title: lesson.title,
              sourcePath: 'foundation/course/${course.id}/unit/${unit.id}',
              content: lesson.content,
              definition: lesson.definition,
              applications: lesson.applications,
              learningOutcomes: lesson.learningOutcomes,
              terms: lesson.keyTerms,
              conceptIds: lesson.conceptIds,
              skillIds: lesson.skillIds,
              knowledgeAreaIds: course.knowledgeAreaIds,
              knowledgeUnitIds: course.knowledgeUnitIds,
              courseId: course.id,
              unitId: unit.id,
              lessonId: lesson.id,
              projectTitles: <String>{
                ...lesson.projects.map((p) => p.title),
                ...course.projects.map((p) => p.title),
              }.toList(growable: false),
            ),
          );
        }
      }
    }

    // Critical security boundary: filter the full candidate set before sort
    // and take(limit), never filter an already-truncated global top-20 list.
    final scopedResults = allowedAreaIds == null
        ? results
        : results
            .where((item) => item.knowledgeAreaIds.any(allowedAreaIds.contains))
            .toList(growable: false);
    scopedResults.sort((a, b) => _score(b, tokens).compareTo(_score(a, tokens)));
    return scopedResults.take(limit).toList(growable: false);
  }

  List<String> _tokens(String text) => text.toLowerCase().split(RegExp(r'[^\\p{L}\\p{N}_]+', unicode: true)).where((token) => token.length > 1).toList(growable: false);

  int _score(AbqariKnowledgeItem item, List<String> tokens) {
    final haystack = [
      item.title,
      item.definition,
      item.content,
      item.applications.join(' '),
      item.learningOutcomes.join(' '),
      item.terms.join(' '),
      item.knowledgeAreaIds.join(' '),
      item.knowledgeUnitIds.join(' '),
      item.projectTitles.join(' '),
    ].join(' ').toLowerCase();
    var score = tokens.where(haystack.contains).length;
    score += tokens.where((token) => item.title.toLowerCase().contains(token)).length;
    score += tokens.where((token) => item.projectTitles.join(' ').toLowerCase().contains(token)).length;
    return score;
  }
}