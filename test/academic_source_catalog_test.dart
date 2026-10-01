import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_source_catalog.dart';

void main() {
  test('canonical curriculum source registry is unique and non-empty', () {
    final ids = AcademicSourceCatalog.all.map((source) => source.id).toSet();
    expect(ids.length, AcademicSourceCatalog.all.length);
    expect(AcademicSourceCatalog.all, isNotEmpty);
    for (final source in AcademicSourceCatalog.all) {
      expect(source.title, isNotEmpty);
      expect(source.publisher, isNotEmpty);
      expect(source.kind, isNotEmpty);
    }
  });
}
