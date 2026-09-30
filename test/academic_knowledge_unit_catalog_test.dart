import 'package:flutter_test/flutter_test.dart';

import '../lib/data/academic/academic_knowledge_area_catalog.dart';
import '../lib/data/academic/academic_knowledge_unit_catalog.dart';

void main() {
  test('canonical knowledge unit catalog is complete and unique', () {
    expect(AcademicKnowledgeAreaCatalog.areas, hasLength(17));
    final expectedUnitNames = AcademicKnowledgeAreaCatalog.areas
        .expand((area) => area.units)
        .toList(growable: false);
    expect(AcademicKnowledgeUnitCatalog.units, hasLength(expectedUnitNames.length));
    expect(AcademicKnowledgeUnitCatalog.units.map((unit) => unit.name).toSet(),
        hasLength(expectedUnitNames.length));

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
