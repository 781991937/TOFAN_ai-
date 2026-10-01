import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('every course exposes a buildable project contract', () {
    final courses = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .toList();

    expect(courses, isNotEmpty);

    for (final course in courses) {
      expect(course.projects, isNotEmpty, reason: course.name);
      for (final project in course.projects) {
        expect(project.requirements, isNotEmpty, reason: project.title);
        expect(project.deliverables, isNotEmpty, reason: project.title);
        expect(project.milestones, isNotEmpty, reason: project.title);
        expect(project.acceptanceCriteria, isNotEmpty, reason: project.title);
        expect(project.implementationTasks, isNotEmpty, reason: project.title);
        expect(project.testCases, isNotEmpty, reason: project.title);
        expect(project.evidenceRequirements, isNotEmpty, reason: project.title);
      }
    }
  });
  test('generated global courses do not use the generic lesson fallback', () {
    final courses = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .where((course) => course.id.contains('-y'))
        .toList();

    expect(courses, isNotEmpty);
    for (final course in courses) {
      expect(
        course.lessons.every(
          (lesson) =>
              !lesson.title.startsWith('الأساس المفاهيمي في ') &&
              !lesson.title.startsWith('البنية والمكونات في '),
        ),
        isTrue,
        reason: 'Generic lesson fallback detected in ${course.name}',
      );
    }
  });
}
