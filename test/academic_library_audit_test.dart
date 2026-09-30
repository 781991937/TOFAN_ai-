import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/data/academic/academic_library_audit.dart';

void main() {
  test('TOFAN Academic Library passes structural and instructional integrity gate', () {
    final report = AcademicLibraryAudit.run();

    expect(report.fields, greaterThanOrEqualTo(1));
    expect(report.universities, greaterThanOrEqualTo(1));
    expect(report.specializations, greaterThanOrEqualTo(1));
    expect(report.courses, greaterThanOrEqualTo(1));
    expect(report.lessons, greaterThanOrEqualTo(1));
    expect(report.isHealthy, isTrue, reason: report.issues.join('\n'));
  });
}
