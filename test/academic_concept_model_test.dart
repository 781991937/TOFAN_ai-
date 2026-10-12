import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test('canonical concept index projects lesson content without replacing its source', () {
    final concepts = AcademicCatalog.concepts;
    final conceptIds = concepts.map((concept) => concept.id).toSet();

    expect(concepts, isNotEmpty);
    expect(concepts.length, AcademicCatalog.conceptCount);
    expect(conceptIds.length, concepts.length);
    expect(concepts.every((concept) => concept.isWellFormed), isTrue);

    final variableConcept = AcademicCatalog.conceptById('concept-python-2');
    expect(variableConcept, isNotNull);
    expect(variableConcept!.title, 'المتغيرات وأنواع البيانات');
    expect(
      variableConcept.definition,
      'المتغير اسم يُستخدم للإشارة إلى قيمة، ونوع البيانات يصف طبيعة تلك القيمة والعمليات المناسبة لها.',
    );
    expect(variableConcept.sourceCourseIds, contains('python'));
    expect(variableConcept.sourceLessonIds, contains('python-2'));
    expect(variableConcept.courseKnowledgeAreaIds, containsAll(['SDF', 'FPL']));
    expect(
      variableConcept.courseKnowledgeUnitIds,
      containsAll(['sdf-01', 'fpl-01']),
    );
    expect(
      variableConcept.assessmentQuestionIds,
      containsAll([
        'python-2/python-2-assessment/q1',
        'python-2/python-2-assessment/q2',
        'python-2/python-2-assessment/q3',
      ]),
    );
    expect(variableConcept.relatedSkillIds, contains('skill-python-2'));
    expect(variableConcept.projectIds, contains('python-2/python-2-project'));
  });

  test('every canonical lesson concept resolves back to its source course and lesson', () {
    final courses = [
      ...AcademicCatalog.foundationCourses,
      ...AcademicCatalog.universities
          .expand((university) => university.colleges)
          .expand((college) => college.specializations)
          .expand((specialization) => specialization.years)
          .expand((year) => year.semesters)
          .expand((semester) => semester.courses),
    ];

    for (final course in courses) {
      for (final lesson in course.lessons) {
        for (final conceptId in lesson.conceptIds) {
          final concept = AcademicCatalog.conceptById(conceptId);
          expect(concept, isNotNull, reason: 'Unresolved concept $conceptId.');
          expect(concept!.sourceCourseIds, contains(course.id));
          expect(concept.sourceLessonIds, contains(lesson.id));
          expect(concept.definition, lesson.definition);
        }
      }
    }
  });

  test('unknown concepts are not synthesized by lookup', () {
    expect(AcademicCatalog.conceptById('concept-not-in-catalog'), isNull);
  });
}
