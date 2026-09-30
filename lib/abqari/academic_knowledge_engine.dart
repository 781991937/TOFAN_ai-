import '../data/academic/academic_catalog.dart';
import 'abqari_models.dart';

class AcademicKnowledgeEngine {
  const AcademicKnowledgeEngine();

  List<AbqariKnowledgeItem> search(String query) {
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
                      final haystack = <String>[field.name, university.name, college.name, specialization.name, course.name, unit.title, lesson.title, lesson.content, ...lesson.keyTerms, ...lesson.learningOutcomes].join(' ').toLowerCase();
                      if (tokens.any(haystack.contains)) {
                        results.add(AbqariKnowledgeItem(
                          id: lesson.id,
                          title: lesson.title,
                          sourcePath: 'field/' + field.id + '/university/' + university.id + '/college/' + college.id + '/specialization/' + specialization.id + '/year/' + year.number.toString() + '/semester/' + semester.number.toString() + '/course/' + course.id + '/unit/' + unit.id,
                          content: lesson.content,
                          terms: lesson.keyTerms,
                          conceptIds: lesson.conceptIds,
                          skillIds: lesson.skillIds,
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
    results.sort((a, b) => _score(b, tokens).compareTo(_score(a, tokens)));
    return results.take(20).toList(growable: false);
  }

  List<String> _tokens(String text) => text.toLowerCase().split(RegExp(r'[^\\p{L}\\p{N}_]+', unicode: true)).where((token) => token.length > 1).toList(growable: false);
  int _score(AbqariKnowledgeItem item, List<String> tokens) {
    final haystack = (item.title + ' ' + item.content + ' ' + item.terms.join(' ')).toLowerCase();
    return tokens.where(haystack.contains).length;
  }
}