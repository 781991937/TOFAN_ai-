import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';
import 'package:tofan_ai/data/academic/academic_knowledge_unit_catalog.dart';

void main() {
  test('AI knowledge area exposes all 12 canonical CS2023-aligned units', () {
    final aiUnits = AcademicKnowledgeUnitCatalog.units
        .where((unit) => unit.areaId == 'AI')
        .toList(growable: false);

    expect(aiUnits, hasLength(12));
    expect(
      aiUnits.map((unit) => unit.id).toSet(),
      containsAll(<String>[
        'ai-01',
        'ai-02',
        'ai-03',
        'ai-04',
        'ai-05',
        'ai-06',
        'ai-07',
        'ai-08',
        'ai-09',
        'ai-10',
        'ai-11',
        'ai-12',
      ]),
    );
  });

  test('AI-specific courses resolve to focused knowledge units', () {
    final courses = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .where((specialization) => specialization.id == 'ai')
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .toList(growable: false);

    final aiIntro = courses.firstWhere((course) => course.id == 'ai-intro');
    expect(aiIntro.knowledgeUnitIds, containsAll(<String>['ai-01', 'ai-03']));

    final allAiUnitIds = <String>{
      for (final course in courses) ...course.knowledgeUnitIds.where((id) => id.startsWith('ai-')),
    };
    expect(allAiUnitIds.length, greaterThanOrEqualTo(2));
  });
}
