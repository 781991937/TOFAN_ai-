import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/academic_knowledge_engine.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';
import 'package:tofan_ai/data/academic/academic_foundation_catalog.dart';
import 'package:tofan_ai/data/academic/academic_project_capability_engine.dart';

void main() {
  test('every specialization references the canonical shared foundations', () {
    final specializations = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .toList();

    expect(specializations, isNotEmpty);
    for (final specialization in specializations) {
      expect(
        specialization.foundationCourseIds,
        containsAll(AcademicFoundationCatalog.foundationCourseIds),
        reason: 'Missing shared foundations in ${specialization.name}',
      );
    }
  });

  test('shared foundations are unique canonical courses with build contracts', () {
    final courses = AcademicFoundationCatalog.courses;
    expect(
      courses.map((course) => course.id).toSet().length,
      courses.length,
    );
    expect(
      courses.map((course) => course.name).toSet().length,
      courses.length,
    );

    for (final course in courses) {
      expect(course.lessons, isNotEmpty);
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

  test('Abqari can retrieve programming and technical English foundations', () {
    const engine = AcademicKnowledgeEngine();
    final programming = engine.search('أساسيات البرمجة الخوارزمية');
    final technicalEnglish = engine.search('الإنجليزية التقنية التوثيق');

    expect(
      programming.any((item) => item.courseId == 'foundation-programming'),
      isTrue,
    );
    expect(
      technicalEnglish.any(
        (item) => item.courseId == 'foundation-technical-english',
      ),
      isTrue,
    );
  });

  test('project capability engine exposes the programming foundation', () {
    const engine = AcademicProjectCapabilityEngine();
    final capabilities = engine.capabilitiesFor('برمجة خوارزمية');

    expect(
      capabilities.any((item) => item.courseId == 'foundation-programming'),
      isTrue,
    );
  });
}
