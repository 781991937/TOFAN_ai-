import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('every specialization exposes four years and eight semesters', () {
    final specializations = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .toList();

    expect(specializations, isNotEmpty);

    for (final specialization in specializations) {
      expect(specialization.years.length, 4, reason: specialization.name);
      expect(
        specialization.years.expand((year) => year.semesters).length,
        8,
        reason: specialization.name,
      );
    }
  });

  test('every course has a deep six-lesson learning path', () {
    final courses = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .toList();

    expect(courses, isNotEmpty);

    for (final course in courses) {
      expect(
        course.lessons.length,
        greaterThanOrEqualTo(6),
        reason: '${course.id} — ${course.name}',
      );
      expect(
        course.lessons.every((lesson) =>
            lesson.learningOutcomes.isNotEmpty &&
            lesson.practices.isNotEmpty &&
            lesson.assessments.isNotEmpty &&
            lesson.projects.isNotEmpty &&
            lesson.skillIds.isNotEmpty),
        isTrue,
        reason: '${course.id} — every lesson must carry learning evidence',
      );
    }
  });

  test('deep lessons remain connected to canonical knowledge units', () {
    final courses = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .toList();

    for (final course in courses) {
      expect(course.knowledgeAreaIds, isNotEmpty, reason: course.name);
      expect(course.knowledgeUnitIds, isNotEmpty, reason: course.name);
    }
  });
}
