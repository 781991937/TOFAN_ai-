import 'package:flutter_test/flutter_test.dart';

import '../lib/data/academic/academic_knowledge_area_catalog.dart';
import '../lib/data/academic/academic_knowledge_unit_catalog.dart';

void main() {
  test('canonical knowledge unit catalog is complete and unique', () {
    expect(AcademicKnowledgeAreaCatalog.areas, hasLength(17));
    expect(AcademicKnowledgeUnitCatalog.units, hasLength(85));

    final ids = AcademicKnowledgeUnitCatalog.units.map((unit) => unit.id).toSet();
    expect(ids, hasLength(85));

    for (final unit in AcademicKnowledgeUnitCatalog.units) {
      expect(
        AcademicKnowledgeAreaCatalog.byId(unit.areaId),
        isNotNull,
        reason: 'Unknown knowledge area for ${unit.id}',
      );
      expect(unit.description, isNotEmpty);
      expect(unit.learningOutcomes, hasLength(3));
    }
  });
}
