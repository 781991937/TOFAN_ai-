import '../../domain/academic/academic_models.dart';
import '../../domain/files/academic_document_models.dart';
import '../../data/academic/academic_catalog.dart';

class AcademicDocumentMapper {
  const AcademicDocumentMapper();

  AcademicDocumentMapping map(AcademicDocument document) {
    final tokens = _tokens(document.content);
    final matches = <AcademicDocumentMatch>[];
    for (final course in _allCourses()) {
      final courseText = [
        course.name,
        course.id,
        ...course.knowledgeAreaIds,
        ...course.knowledgeUnitIds,
      ].join(' ');
      final courseScore = _score(courseText, tokens);
      if (courseScore > 0) {
        matches.add(_match(document, AcademicDocumentTargetType.course, course.id,
            courseScore, course.name));
      }

      for (final unit in course.normalizedUnits) {
        final unitText = [unit.id, unit.title].join(' ');
        final unitScore = _score(unitText, tokens);
        if (unitScore > 0) {
          matches.add(_match(document, AcademicDocumentTargetType.knowledgeUnit,
              unit.id, unitScore, unit.title));
        }
        for (final lesson in unit.lessons) {
          final lessonText = [
            lesson.id,
            lesson.title,
            lesson.definition,
            lesson.content,
            ...lesson.keyTerms,
            ...lesson.learningOutcomes,
          ].join(' ');
          final lessonScore = _score(lessonText, tokens);
          if (lessonScore > 0) {
            matches.add(_match(document, AcademicDocumentTargetType.lesson,
                lesson.id, lessonScore, lesson.title));
          }
          for (final conceptId in lesson.conceptIds) {
            final conceptScore = _score(conceptId, tokens);
            if (conceptScore > 0) {
              matches.add(_match(document, AcademicDocumentTargetType.concept,
                  conceptId, conceptScore, conceptId));
            }
          }
          for (final skillId in lesson.skillIds) {
            final skillScore = _score(skillId, tokens);
            if (skillScore > 0) {
              matches.add(_match(document, AcademicDocumentTargetType.skill,
                  skillId, skillScore, skillId));
            }
          }
        }
      }
    }
    return AcademicDocumentMapping(
      documentId: document.id,
      matches: List.unmodifiable(_deduplicate(matches)),
    );
  }

  AcademicDocumentMatch _match(
    AcademicDocument document,
    AcademicDocumentTargetType type,
    String id,
    int score,
    String evidence,
  ) {
    return AcademicDocumentMatch(
      documentId: document.id,
      targetType: type,
      targetId: id,
      confidence: score >= 3 ? 1.0 : score >= 2 ? 0.75 : 0.5,
      evidence: evidence,
    );
  }

  List<AcademicDocumentMatch> _deduplicate(List<AcademicDocumentMatch> input) {
    final seen = <String>{};
    return input.where((match) => seen.add(
      '${match.targetType.name}:${match.targetId}',
    )).toList(growable: false);
  }

  int _score(String text, List<String> tokens) {
    final haystack = text.toLowerCase();
    return tokens.where((token) => haystack.contains(token)).length;
  }

  static const _mappingStopWords = <String>{
    'a', 'an', 'and', 'at', 'by', 'content', 'document', 'for', 'from',
    'in', 'no', 'of', 'on', 'or', 'terms', 'the', 'to', 'with',
    'academic', 'catalog', 'unknown',
    'في', 'من', 'مع', 'على', 'إلى', 'عن', 'هذا', 'هذه', 'ذلك',
    'تلك', 'غير', 'موجود', 'موجودة', 'الموجود', 'الموجودة', 'المكتبة',
    'المحتوى', 'وثيقة', 'مستند', 'أكاديمي', 'الأكاديمية', 'المصطلحات',
  };

  List<String> _tokens(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^\p{L}\p{N}_]+', unicode: true))
      .where((token) => token.length > 1 && !_mappingStopWords.contains(token))
      .toList(growable: false);

  List<AcademicCourse> _allCourses() {
    final courses = <AcademicCourse>[
      ...AcademicCatalog.foundationCourses,
      ...AcademicCatalog.universities
          .expand((university) => university.colleges)
          .expand((college) => college.specializations)
          .expand((specialization) => specialization.years)
          .expand((year) => year.semesters)
          .expand((semester) => semester.courses),
    ];
    final unique = <String, AcademicCourse>{};
    for (final course in courses) {
      unique[course.id] = course;
    }
    return unique.values.toList(growable: false);
  }
}
