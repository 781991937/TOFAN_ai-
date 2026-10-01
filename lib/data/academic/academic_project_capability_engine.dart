import '../../domain/academic/academic_models.dart';
import 'academic_catalog.dart';

/// Turns the canonical academic library into a project-oriented capability map.
///
/// This is derived from existing courses and lessons; it does not invent new
/// academic content. A capability is evidence that the library contains
/// concepts, skills, applications, practices, assessments, and projects
/// relevant to a requested build.
class AcademicProjectCapability {
  const AcademicProjectCapability({
    required this.courseId,
    required this.courseName,
    required this.specializationId,
    required this.specializationName,
    required this.year,
    required this.semester,
    required this.knowledgeAreaIds,
    required this.knowledgeUnitIds,
    required this.skillIds,
    required this.conceptIds,
    required this.lessonIds,
    required this.projectTitles,
  });

  final String courseId;
  final String courseName;
  final String specializationId;
  final String specializationName;
  final int year;
  final int semester;
  final List<String> knowledgeAreaIds;
  final List<String> knowledgeUnitIds;
  final List<String> skillIds;
  final List<String> conceptIds;
  final List<String> lessonIds;
  final List<String> projectTitles;

  bool get hasBuildEvidence =>
      lessonIds.isNotEmpty &&
      skillIds.isNotEmpty &&
      projectTitles.isNotEmpty;
}

/// A project-oriented view of the library.
///
/// The engine answers: "Which existing academic material can contribute to
/// this build?" It does not claim that one course is sufficient for a complete
/// production system. Cross-disciplinary projects are expected to combine
/// multiple capabilities.
class AcademicProjectCapabilityEngine {
  const AcademicProjectCapabilityEngine();

  List<AcademicProjectCapability> capabilitiesFor(String request) {
    final tokens = _tokens(request);
    final result = <AcademicProjectCapability>[];

    for (final field in AcademicCatalog.fields) {
      for (final university in field.universities) {
        for (final college in university.colleges) {
          for (final specialization in college.specializations) {
            for (final year in specialization.years) {
              for (final semester in year.semesters) {
                for (final course in semester.courses) {
                  final score = _score(course, tokens);
                  if (score == 0) continue;

                  final lessons = course.lessons.where((lesson) {
                    final haystack = [
                      lesson.title,
                      lesson.content,
                      lesson.definition,
                      ...lesson.applications,
                      ...lesson.keyTerms,
                      ...lesson.learningOutcomes,
                      ...lesson.projects.map((project) => project.title),
                      ...lesson.projects.map((project) => project.description),
                    ].join(' ').toLowerCase();
                    return tokens.any(haystack.contains);
                  }).toList(growable: false);

                  final selectedLessons =
                      lessons.isEmpty ? course.lessons : lessons;
                  result.add(
                    AcademicProjectCapability(
                      courseId: course.id,
                      courseName: course.name,
                      specializationId: specialization.id,
                      specializationName: specialization.name,
                      year: year.number,
                      semester: semester.number,
                      knowledgeAreaIds: course.knowledgeAreaIds,
                      knowledgeUnitIds: course.knowledgeUnitIds,
                      skillIds: {
                        for (final lesson in selectedLessons) ...lesson.skillIds,
                      }.toList(growable: false),
                      conceptIds: {
                        for (final lesson in selectedLessons)
                          ...lesson.conceptIds,
                      }.toList(growable: false),
                      lessonIds:
                          selectedLessons.map((lesson) => lesson.id).toList(),
                      projectTitles: {
                        for (final lesson in selectedLessons)
                          ...lesson.projects.map((project) => project.title),
                      }.toList(growable: false),
                    ),
                  );
                }
              }
            }
          }
        }
      }
    }

    result.sort((a, b) {
      final scoreB = _capabilityScore(b, tokens);
      final scoreA = _capabilityScore(a, tokens);
      return scoreB.compareTo(scoreA);
    });
    return result.take(30).toList(growable: false);
  }

  bool canStartBuild(String request) =>
      capabilitiesFor(request).any((item) => item.hasBuildEvidence);

  List<String> missingEvidence(String request) {
    final matches = capabilitiesFor(request);
    if (matches.isEmpty) {
      return const [
        'لا توجد مطابقة كافية في المكتبة الحالية لهذا المتطلب.',
        'يجب إضافة أو استكمال المعرفة الأكاديمية قبل أن يدّعي الوكيل القدرة على البناء.',
      ];
    }

    final gaps = <String>[];
    if (!matches.any((item) => item.knowledgeUnitIds.isNotEmpty)) {
      gaps.add('وحدات معرفية دقيقة');
    }
    if (!matches.any((item) => item.skillIds.isNotEmpty)) {
      gaps.add('مهارات قابلة للإثبات');
    }
    if (!matches.any((item) => item.projectTitles.isNotEmpty)) {
      gaps.add('مشاريع تطبيقية');
    }
    return gaps;
  }

  int _capabilityScore(
    AcademicProjectCapability capability,
    List<String> tokens,
  ) {
    final course = AcademicCatalog.universities
        .expand((university) => university.colleges)
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .firstWhere((course) => course.id == capability.courseId);
    return _score(course, tokens) +
        capability.skillIds.length +
        capability.projectTitles.length;
  }

  int _score(AcademicCourse course, List<String> tokens) {
    final haystack = [
      course.name,
      ...course.knowledgeAreaIds,
      ...course.knowledgeUnitIds,
      ...course.lessons.map((lesson) => lesson.title),
      ...course.lessons.map((lesson) => lesson.content),
      ...course.lessons.expand((lesson) => lesson.keyTerms),
      ...course.lessons.expand((lesson) => lesson.applications),
      ...course.lessons.expand(
        (lesson) => lesson.projects.map((project) => project.title),
      ),
    ].join(' ').toLowerCase();
    return tokens.where(haystack.contains).length;
  }

  List<String> _tokens(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^\p{L}\p{N}_]+', unicode: true))
      .where((token) => token.length > 1)
      .toList(growable: false);
}
