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
    required this.projectIds,
    required this.projectRequirements,
    required this.implementationTasks,
    required this.testCases,
    required this.evidenceRequirements,
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
  final List<String> projectIds;
  final List<String> projectRequirements;
  final List<String> implementationTasks;
  final List<String> testCases;
  final List<String> evidenceRequirements;

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
class AcademicProjectCapabilityPlan {
  const AcademicProjectCapabilityPlan({
    required this.request,
    required this.capabilities,
    required this.courseIds,
    required this.specializationIds,
    required this.knowledgeAreaIds,
    required this.knowledgeUnitIds,
    required this.skillIds,
    required this.conceptIds,
    required this.lessonIds,
    required this.projectIds,
    required this.projectRequirements,
    required this.implementationTasks,
    required this.testCases,
    required this.evidenceRequirements,
  });

  final String request;
  final List<AcademicProjectCapability> capabilities;
  final List<String> courseIds;
  final List<String> specializationIds;
  final List<String> knowledgeAreaIds;
  final List<String> knowledgeUnitIds;
  final List<String> skillIds;
  final List<String> conceptIds;
  final List<String> lessonIds;
  final List<String> projectIds;
  final List<String> projectRequirements;
  final List<String> implementationTasks;
  final List<String> testCases;
  final List<String> evidenceRequirements;

  bool get isCrossDisciplinary => specializationIds.length > 1;
  bool get hasBuildContract =>
      projectRequirements.isNotEmpty &&
      implementationTasks.isNotEmpty &&
      testCases.isNotEmpty &&
      evidenceRequirements.isNotEmpty;
}

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
                        ...course.projects.map((project) => project.title),
                        for (final lesson in selectedLessons)
                          ...lesson.projects.map((project) => project.title),
                      }.toList(growable: false),
                      projectIds: {
                        ...course.projects.map((project) => project.id),
                        for (final lesson in selectedLessons)
                          ...lesson.projects.map((project) => project.id),
                      }.toList(growable: false),
                      projectRequirements: {
                        ...course.projects.expand((project) => project.requirements),
                        for (final lesson in selectedLessons)
                          ...lesson.projects.expand((project) => project.requirements),
                      }.toList(growable: false),
                      implementationTasks: {
                        ...course.projects.expand((project) => project.implementationTasks),
                        for (final lesson in selectedLessons)
                          ...lesson.projects.expand((project) => project.implementationTasks),
                      }.toList(growable: false),
                      testCases: {
                        ...course.projects.expand((project) => project.testCases),
                        for (final lesson in selectedLessons)
                          ...lesson.projects.expand((project) => project.testCases),
                      }.toList(growable: false),
                      evidenceRequirements: {
                        ...course.projects.expand((project) => project.evidenceRequirements),
                        for (final lesson in selectedLessons)
                          ...lesson.projects.expand((project) => project.evidenceRequirements),
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

    // Shared foundations are canonical and referenced by all specializations.
    // Include them as a single foundation capability so project planning can
    // account for programming, computing, and technical-English prerequisites.
    for (final course in AcademicCatalog.foundationCourses) {
      final lessons = course.lessons;
      result.add(
        AcademicProjectCapability(
          courseId: course.id,
          courseName: course.name,
          specializationId: 'shared-foundation',
          specializationName: 'الأساسيات المشتركة',
          year: 0,
          semester: 0,
          knowledgeAreaIds: course.knowledgeAreaIds,
          knowledgeUnitIds: course.knowledgeUnitIds,
          skillIds: {
            ...lessons.expand((lesson) => lesson.skillIds),
            ...course.projects.expand((project) => project.skillIds),
          }.toList(growable: false),
          conceptIds: {
            ...lessons.expand((lesson) => lesson.conceptIds),
            ...course.projects.expand((project) => project.conceptIds),
          }.toList(growable: false),
          lessonIds: lessons.map((lesson) => lesson.id).toList(growable: false),
          projectTitles: course.projects.map((project) => project.title).toList(growable: false),
          projectIds: course.projects.map((project) => project.id).toList(growable: false),
          projectRequirements: course.projects.expand((project) => project.requirements).toList(growable: false),
          implementationTasks: course.projects.expand((project) => project.implementationTasks).toList(growable: false),
          testCases: course.projects.expand((project) => project.testCases).toList(growable: false),
          evidenceRequirements: course.projects.expand((project) => project.evidenceRequirements).toList(growable: false),
        ),
      );
    }

    result.sort((a, b) {
      final scoreB = _capabilityScore(b, tokens);
      final scoreA = _capabilityScore(a, tokens);
      return scoreB.compareTo(scoreA);
    });
    return result.take(30).toList(growable: false);
  }

  AcademicProjectCapabilityPlan planFor(String request) {
    final matches = capabilitiesFor(request);
    // Keep the plan derived from the canonical library. Select the strongest
    // matching capability from each specialization first, then fill remaining
    // slots with the highest-ranked capabilities. This makes multi-disciplinary
    // builds explicit without creating a second knowledge base.
    final selected = <AcademicProjectCapability>[];
    final seenSpecializations = <String>{};
    for (final capability in matches) {
      if (seenSpecializations.add(capability.specializationId)) {
        selected.add(capability);
      }
      if (selected.length == 12) break;
    }
    if (selected.length < 12) {
      for (final capability in matches) {
        if (selected.any((item) => item.courseId == capability.courseId)) continue;
        selected.add(capability);
        if (selected.length == 12) break;
      }
    }

    List<String> unique(Iterable<String> values) => values.toSet().toList(growable: false);
    return AcademicProjectCapabilityPlan(
      request: request,
      capabilities: selected,
      courseIds: unique(selected.map((item) => item.courseId)),
      specializationIds: unique(selected.map((item) => item.specializationId)),
      knowledgeAreaIds: unique(selected.expand((item) => item.knowledgeAreaIds)),
      knowledgeUnitIds: unique(selected.expand((item) => item.knowledgeUnitIds)),
      skillIds: unique(selected.expand((item) => item.skillIds)),
      conceptIds: unique(selected.expand((item) => item.conceptIds)),
      lessonIds: unique(selected.expand((item) => item.lessonIds)),
      projectIds: unique(selected.expand((item) => item.projectIds)),
      projectRequirements: unique(selected.expand((item) => item.projectRequirements)),
      implementationTasks: unique(selected.expand((item) => item.implementationTasks)),
      testCases: unique(selected.expand((item) => item.testCases)),
      evidenceRequirements: unique(selected.expand((item) => item.evidenceRequirements)),
    );
  }

  bool canStartBuild(String request) => planFor(request).capabilities.any(
        (item) => item.hasBuildEvidence,
      );

  List<String> missingEvidence(String request) {
    final matches = planFor(request).capabilities;
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
        capability.projectTitles.length +
        capability.projectRequirements.length +
        capability.testCases.length +
        capability.evidenceRequirements.length;
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
      ...course.projects.map((project) => project.title),
      ...course.projects.map((project) => project.description),
      ...course.projects.expand((project) => project.requirements),
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
