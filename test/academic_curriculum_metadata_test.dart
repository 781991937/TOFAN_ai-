import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';
import 'package:tofan_ai/data/academic/academic_library_audit.dart';
import 'package:tofan_ai/domain/academic/academic_metadata.dart';

void main() {
  test('curriculum profile rejects impossible delivery metadata', () {
    const profile = AcademicCourseProfile(
      credits: 3,
      contactHours: 30,
      practicalHours: 35,
      complexity: AcademicCourseComplexity.core,
    );
    expect(profile.isValid, isFalse);
  });

  test('published content requires provenance source', () {
    const provenance = AcademicContentProvenance(
      status: AcademicPublicationStatus.published,
    );
    expect(provenance.hasSource, isFalse);
    expect(provenance.isReviewable, isTrue);
  });

  test('library audit exposes curriculum metadata gaps separately', () {
    final report = AcademicLibraryAudit.run();
    expect(report.curriculumMetadataGaps, isNotEmpty);
    expect(report.courses, greaterThan(0));
    expect(report.lessons, greaterThan(0));
    expect(AcademicCatalog.fields, isNotEmpty);
  });
}
