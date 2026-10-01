import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_project_capability_engine.dart';

void main() {
  test('project capability engine derives build evidence from the library', () {
    const engine = AcademicProjectCapabilityEngine();
    final matches =
        engine.capabilitiesFor('نظام ويب مع قاعدة بيانات ومصادقة وأمن');

    expect(matches, isNotEmpty);
    expect(
      engine.canStartBuild('نظام ويب مع قاعدة بيانات ومصادقة وأمن'),
      isTrue,
    );
    expect(matches.any((item) => item.skillIds.isNotEmpty), isTrue);
    expect(matches.any((item) => item.projectTitles.isNotEmpty), isTrue);
    expect(matches.any((item) => item.projectIds.isNotEmpty), isTrue);
    expect(matches.any((item) => item.projectRequirements.isNotEmpty), isTrue);
    expect(matches.any((item) => item.testCases.isNotEmpty), isTrue);
    expect(matches.any((item) => item.evidenceRequirements.isNotEmpty), isTrue);
  });

  test('unknown requirements are not treated as known project capability', () {
    const engine = AcademicProjectCapabilityEngine();
    expect(
      engine.canStartBuild('تقنية غير موجودة في المكتبة xyzq-unknown'),
      isFalse,
    );
    expect(
      engine.missingEvidence('تقنية غير موجودة في المكتبة xyzq-unknown'),
      isNotEmpty,
    );
  });

  test('course-level project blueprints are consumed even without lesson project titles', () {
    const engine = AcademicProjectCapabilityEngine();
    final matches = engine.capabilitiesFor('نظام ويب مع قاعدة بيانات ومصادقة وأمن');
    expect(
      matches.any((item) =>
          item.projectIds.isNotEmpty &&
          item.projectRequirements.isNotEmpty &&
          item.implementationTasks.isNotEmpty),
      isTrue,
    );
  });
  test('multidisciplinary build plan aggregates canonical courses and evidence', () {
    const engine = AcademicProjectCapabilityEngine();
    final plan = engine.planFor('نظام ذكي ويب مع قاعدة بيانات وشبكة وأمن');

    expect(plan.capabilities, isNotEmpty);
    expect(plan.courseIds, isNotEmpty);
    expect(plan.knowledgeUnitIds, isNotEmpty);
    expect(plan.skillIds, isNotEmpty);
    expect(plan.lessonIds, isNotEmpty);
    expect(plan.projectIds, isNotEmpty);
    expect(plan.projectRequirements, isNotEmpty);
    expect(plan.implementationTasks, isNotEmpty);
    expect(plan.testCases, isNotEmpty);
    expect(plan.evidenceRequirements, isNotEmpty);
  });

}
