import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';
import 'package:tofan_ai/domain/academic/academic_metadata.dart';

void main() {
  test('generated curriculum courses carry valid weight and project-build contracts', () {
    final courses = AcademicCatalog.universities
        .expand((u) => u.colleges)
        .expand((c) => c.specializations)
        .expand((s) => s.years)
        .expand((y) => y.semesters)
        .expand((s) => s.courses)
        .where((course) => course.id.contains('-y'))
        .toList();

    expect(courses, isNotEmpty);
    for (final course in courses) {
      final profile = course.curriculumProfile;
      expect(profile, isNotNull, reason: 'Generated course needs curriculum metadata: ' + course.id);
      expect(profile!.isValid, isTrue, reason: 'Invalid curriculum profile: ' + course.id);
      expect(course.lessons.length, greaterThanOrEqualTo(6));
      expect(course.knowledgeAreaIds, isNotEmpty);
      expect(course.knowledgeUnitIds, isNotEmpty);
      expect(course.projects, isNotEmpty);

      for (final project in course.projects) {
        expect(project.requirements, isNotEmpty);
        expect(project.deliverables, isNotEmpty);
        expect(project.milestones, isNotEmpty);
        expect(project.acceptanceCriteria, isNotEmpty);
        expect(project.implementationTasks, isNotEmpty);
        expect(project.testCases, isNotEmpty);
        expect(project.evidenceRequirements, isNotEmpty);
      }
    }
  });

  test('derived prerequisites never point outside the specialization or to self', () {
    for (final university in AcademicCatalog.universities) {
      for (final college in university.colleges) {
        for (final specialization in college.specializations) {
          final courses = specialization.years
              .expand((year) => year.semesters)
              .expand((semester) => semester.courses)
              .toList();
          final ids = courses.map((course) => course.id).toSet();

          for (final course in courses) {
            expect(course.prerequisiteCourseIds, isNot(contains(course.id)));
            expect(
              course.prerequisiteCourseIds.every(ids.contains),
              isTrue,
              reason: 'Dangling prerequisite in ' + specialization.id + '/' + course.id,
            );
          }
        }
      }
    }
  });

  test('generated profiles distinguish foundation, core, advanced and capstone work', () {
    final courses = AcademicCatalog.universities
        .expand((u) => u.colleges)
        .expand((c) => c.specializations)
        .expand((s) => s.years)
        .expand((y) => y.semesters)
        .expand((s) => s.courses)
        .where((course) => course.id.contains('-y'))
        .toList();

    expect(
      courses.any((course) => course.curriculumProfile?.complexity == AcademicCourseComplexity.foundation),
      isTrue,
    );
    expect(
      courses.any((course) => course.curriculumProfile?.complexity == AcademicCourseComplexity.core),
      isTrue,
    );
    expect(
      courses.any((course) => course.curriculumProfile?.complexity == AcademicCourseComplexity.advanced),
      isTrue,
    );
    expect(
      courses.any((course) => course.curriculumProfile?.complexity == AcademicCourseComplexity.capstone),
      isTrue,
    );
  });
}
