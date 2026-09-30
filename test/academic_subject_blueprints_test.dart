import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('every generated course has six subject-specific lesson stages', () {
    final courses = AcademicCatalog.universities
        .expand((u) => u.colleges)
        .expand((c) => c.specializations)
        .expand((s) => s.years)
        .expand((y) => y.semesters)
        .expand((s) => s.courses)
        .toList();

    expect(courses, isNotEmpty);

    for (final course in courses) {
      expect(course.lessons.length, greaterThanOrEqualTo(6));
      final firstSix = course.lessons.take(6).toList();
      expect(firstSix.map((l) => l.title).toSet().length, firstSix.length);
      expect(firstSix.every((l) => l.content.length >= 180), isTrue);
      expect(firstSix.every((l) => l.keyTerms.length >= 4), isTrue);
      expect(firstSix.every((l) => l.examples.isNotEmpty && l.applications.isNotEmpty), isTrue);
      expect(firstSix.every((l) => l.assessments.isNotEmpty && l.projects.isNotEmpty), isTrue);
      expect(firstSix.every((l) => l.conceptIds.isNotEmpty && l.skillIds.isNotEmpty), isTrue);
    }
  });

  test('representative specializations expose distinct domain content', () {
    final all = AcademicCatalog.universities
        .expand((u) => u.colleges)
        .expand((c) => c.specializations)
        .expand((s) => s.years)
        .expand((y) => y.semesters)
        .expand((s) => s.courses)
        .toList();

    final names = all.map((course) => course.name).toSet();
    for (final name in [
      'الذكاء الاصطناعي',
      'تطوير الويب',
      'تعلم الآلة',
      'أمن تطبيقات الويب',
      'رسوميات الحاسوب 1',
    ]) {
      expect(names.contains(name), isTrue);
    }

    final ai = all.firstWhere((course) => course.name == 'الذكاء الاصطناعي');
    final web = all.firstWhere((course) => course.name == 'تطوير الويب');
    expect(ai.lessons.first.title, contains('الوكيل'));
    expect(web.lessons.first.title, contains('الويب'));
  });
}
