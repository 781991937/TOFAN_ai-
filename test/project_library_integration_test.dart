import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/abqari/project_engine.dart';
import 'package:tofan_ai/data/academic/academic_project_capability_engine.dart';
import 'package:tofan_ai/data/academic/academic_lesson_blueprints.dart';

void main() {
  test('project capability engine derives build evidence from the canonical library', () {
    const engine = AcademicProjectCapabilityEngine();
    final capabilities = engine.capabilitiesFor('نظام ويب آمن مع قاعدة بيانات وذكاء اصطناعي');

    expect(capabilities, isNotEmpty);
    expect(
      capabilities.any(
        (item) =>
            item.courseId.isNotEmpty &&
            item.lessonIds.isNotEmpty &&
            item.knowledgeUnitIds.isNotEmpty &&
            item.skillIds.isNotEmpty &&
            item.projectTitles.isNotEmpty,
      ),
      isTrue,
    );
    expect(engine.canStartBuild('نظام ويب آمن مع قاعدة بيانات'), isTrue);
  });

  test('Abqari project plan keeps canonical course, lesson, unit, and project traceability', () {
    const engine = AbqariProjectEngine();
    final plan = engine.plan(
      const AbqariProjectRequest(
        idea: 'نظام ويب آمن لإدارة البيانات',
      ),
    );

    expect(plan.sourceCourseIds, isNotEmpty);
    expect(plan.sourceLessonIds, isNotEmpty);
    expect(plan.sourceKnowledgeUnitIds, isNotEmpty);
    expect(plan.sourceProjectTitles, isNotEmpty);
    expect(plan.sourceProjectRequirements, isNotEmpty);
    expect(plan.sourceImplementationTasks, isNotEmpty);
    expect(plan.sourceTestCases, isNotEmpty);
    expect(plan.sourceEvidenceRequirements, isNotEmpty);
  });
$add}
