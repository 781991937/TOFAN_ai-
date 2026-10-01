import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/data/academic/academic_library_audit.dart';
import 'package:tofan_ai/data/academic/academic_knowledge_area_catalog.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('TOFAN Academic Library passes structural and instructional integrity gate', () {
    final report = AcademicLibraryAudit.run();

    expect(report.fields, greaterThanOrEqualTo(1));
    expect(report.universities, greaterThanOrEqualTo(1));
    expect(report.specializations, greaterThanOrEqualTo(1));
    expect(report.courses, greaterThanOrEqualTo(1));
    expect(report.lessons, greaterThanOrEqualTo(1));
    expect(report.isHealthy, isTrue, reason: report.issues.join('\n'));
    expect(AcademicKnowledgeAreaCatalog.areas.length, 17);
    expect(
      AcademicKnowledgeAreaCatalog.areas.map((area) => area.id).toSet().length,
      17,
    );

    final courses = <dynamic>[];
    for (final university in AcademicCatalog.universities) {
      for (final college in university.colleges) {
        for (final specialization in college.specializations) {
          for (final year in specialization.years) {
            for (final semester in year.semesters) {
              courses.addAll(semester.courses);
            }
          }
        }
      }
    }
    expect(courses, isNotEmpty);
    expect(
      courses.every((course) => course.provenance.hasSource),
      isTrue,
      reason: 'Every canonical course must carry provenance before publication.',
    );
    expect(
      courses.expand((course) => course.lessons).every((lesson) => lesson.provenance.hasSource),
      isTrue,
      reason: 'Every canonical lesson must carry provenance before publication.',
    );
  });
}
