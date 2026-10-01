import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('previously generic curriculum gaps use subject-aware blueprints', () {
    final courses = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses);

    final byName = <String, dynamic>{
      for (final course in courses) course.name: course,
    };

    expect(
      byName['المترجمات'].lessons.first.title,
      isNot(contains('الأساس المفاهيمي')),
    );
    expect(
      byName['أساسيات الحوسبة'].lessons.first.title,
      isNot(contains('الأساس المفاهيمي')),
    );
    expect(
      byName['اختبار الاختراق الأخلاقي 1'].lessons.first.title,
      isNot(contains('الأساس المفاهيمي')),
    );
    expect(
      byName['الهجوم والدفاع في المختبرات الأمنية'].lessons.first.title,
      isNot(contains('الأساس المفاهيمي')),
    );
    expect(
      byName['تقييم الاختراق وكتابة التقارير'].lessons.first.title,
      isNot(contains('الأساس المفاهيمي')),
    );
  });
}
