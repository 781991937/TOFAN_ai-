import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/data/academic/academic_library_buildability_audit.dart';

void main() {
  test('library buildability audit covers every canonical specialization', () {
    final reports = AcademicLibraryBuildabilityAudit.run();

    expect(reports, isNotEmpty);
    expect(reports.every((report) => report.courseCount > 0), isTrue);
    expect(reports.map((report) => report.specializationId).toSet().length,
        reports.length);
  });

  test('all canonical specializations pass the current buildability gate', () {
    final reports = AcademicLibraryBuildabilityAudit.run();

    expect(reports, isNotEmpty);
    expect(
      reports.every((report) => report.isComplete),
      isTrue,
      reason: reports
          .where((report) => !report.isComplete)
          .map((report) => '${report.specializationName}: ${report.findings.join(' | ')}')
          .join('\n'),
    );
    expect(
      reports.every((report) =>
          report.partialCourses == 0 && report.missingCourses == 0),
      isTrue,
      reason: reports
          .where((report) =>
              report.partialCourses != 0 || report.missingCourses != 0)
          .map((report) =>
              '${report.specializationName}: partial=${report.partialCourses}, missing=${report.missingCourses}')
          .join('\n'),
    );
  });

  test('a canonical project must expose the full build contract', () {
    final courses = AcademicLibraryBuildabilityAudit.courses();

    expect(courses, isNotEmpty);
    expect(
      courses.every((course) =>
          course.knowledgeUnitCount > 0 &&
          course.projectCount > 0 &&
          course.skillCount > 0),
      isTrue,
    );
  });

  test('buildability matrix validates course delivery metadata and dependencies', () {
    final courses = AcademicLibraryBuildabilityAudit.courses();

    expect(
      courses.every(
        (course) => !course.findings.any(
          (finding) =>
              finding.contains('بيانات وزن/تقديم') ||
              finding.contains('متطلب سابق غير صالح أو ذاتي') ||
              finding.contains('دورة في Prerequisite Graph'),
        ),
      ),
      isTrue,
    );
  });
}
