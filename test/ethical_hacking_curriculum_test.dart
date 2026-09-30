import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('cybersecurity specialization includes an ethical hacking pathway', () {
    final specialization = AcademicCatalog.universities
        .first
        .colleges
        .first
        .specializations
        .firstWhere((item) => item.id == 'cybersecurity');

    final courseNames = [
      for (final year in specialization.years)
        for (final semester in year.semesters)
          for (final course in semester.courses) course.name,
    ];

    expect(courseNames, contains('اختبار الاختراق الأخلاقي 1'));
    expect(courseNames, contains('اختبار الاختراق الأخلاقي 2'));
    expect(courseNames, contains('الهجوم والدفاع في المختبرات الأمنية'));
    expect(courseNames, contains('تقييم الاختراق وكتابة التقارير'));
    expect(courseNames.length, 24);
  });
}
