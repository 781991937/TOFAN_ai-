import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/abqari/abqari_models.dart';
import 'package:tofan_ai/abqari/project_engine.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';

void main() {
  test(
    'real multidisciplinary system is fully traceable to the canonical academic library',
    () {
      const idea = 'نظام ويب آمن لإدارة البيانات مع مكوّن ذكاء اصطناعي';
      const engine = AbqariProjectEngine();

      final plan = engine.plan(const AbqariProjectRequest(idea: idea));

      expect(plan.knowledge, isNotEmpty);
      expect(plan.sourceCourseIds, isNotEmpty);
      expect(plan.sourceKnowledgeUnitIds, isNotEmpty);
      expect(plan.sourceLessonIds, isNotEmpty);
      expect(plan.sourceProjectTitles, isNotEmpty);
      expect(plan.sourceProjectRequirements, isNotEmpty);
      expect(plan.sourceImplementationTasks, isNotEmpty);
      expect(plan.sourceTestCases, isNotEmpty);
      expect(plan.sourceEvidenceRequirements, isNotEmpty);
      expect(plan.knowledgeGaps, isEmpty);

      final courses = [
        ...AcademicCatalog.foundationCourses,
        ...AcademicCatalog.universities
            .expand((university) => university.colleges)
            .expand((college) => college.specializations)
            .expand((specialization) => specialization.years)
            .expand((year) => year.semesters)
            .expand((semester) => semester.courses),
      ];

      final sourceCourses = courses
          .where((course) => plan.sourceCourseIds.contains(course.id))
          .toList(growable: false);

      expect(sourceCourses.length, plan.sourceCourseIds.toSet().length);

      final sourceLessons = sourceCourses
          .expand((course) => course.lessons)
          .where((lesson) => plan.sourceLessonIds.contains(lesson.id))
          .toList(growable: false);

      expect(sourceLessons.length, plan.sourceLessonIds.toSet().length);

      final sourceProjects = sourceCourses
          .expand(
            (course) => [
              ...course.projects,
              ...course.lessons.expand((lesson) => lesson.projects),
            ],
          )
          .toList(growable: false);

      expect(
        sourceProjects
            .where((project) => plan.sourceProjectTitles.contains(project.title))
            .isNotEmpty,
        isTrue,
      );

      expect(
        plan.capabilityPlanForApproval(),
        isTrue,
      );
    },
  );
}

extension on AbqariProjectPlan {
  bool capabilityPlanForApproval() {
    final hasContract = sourceProjectRequirements.isNotEmpty &&
        sourceImplementationTasks.isNotEmpty &&
        sourceTestCases.isNotEmpty &&
        sourceEvidenceRequirements.isNotEmpty;
    final hasCrossDomainEvidence = disciplines.length >= 2;
    return hasContract && hasCrossDomainEvidence;
  }
}
