import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('every course exposes an integrated project blueprint', () {
    final courses = AcademicCatalog.universities
        .expand((u) => u.colleges)
        .expand((c) => c.specializations)
        .expand((s) => s.years)
        .expand((y) => y.semesters)
        .expand((s) => s.courses)
        .toList();

    expect(courses, isNotEmpty);
    for (final course in courses) {
      expect(course.projects, isNotEmpty, reason: course.name);
      final project = course.projects.first;
      expect(project.requirements, isNotEmpty, reason: course.name);
      expect(project.deliverables, isNotEmpty, reason: course.name);
      expect(project.milestones, isNotEmpty, reason: course.name);
      expect(project.acceptanceCriteria, isNotEmpty, reason: course.name);
      expect(project.skillIds, isNotEmpty, reason: course.name);
      expect(project.conceptIds, isNotEmpty, reason: course.name);
    }
  });
}
