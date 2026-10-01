import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/project_engine.dart';
import 'package:tofan_ai/abqari/abqari_models.dart';

void main() {
  test('project planning preserves traceability to the academic library', () {
    const engine = AbqariProjectEngine();
    final plan = engine.plan(
      const AbqariProjectRequest(idea: 'ابن نظام ذكاء اصطناعي يستخدم البيانات والشبكات'),
    );

    expect(plan.knowledge, isNotEmpty);
    expect(plan.sourceLessonIds, isNotEmpty);
    expect(plan.sourceCourseIds, isNotEmpty);
    expect(plan.sourceKnowledgeUnitIds, isNotEmpty);
    expect(plan.sourceProjectTitles, isNotEmpty);
    expect(plan.skills, isNotEmpty);
    expect(plan.sourceProjectRequirements, isNotEmpty);
    expect(plan.sourceImplementationTasks, isNotEmpty);
    expect(plan.sourceTestCases, isNotEmpty);
    expect(plan.sourceEvidenceRequirements, isNotEmpty);
  });
}
