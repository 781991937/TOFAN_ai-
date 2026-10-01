import '../../domain/academic/academic_models.dart';
import 'academic_catalog.dart';

enum AcademicBuildabilityStatus { complete, partial, missing }

class AcademicCourseBuildabilityAudit {
  const AcademicCourseBuildabilityAudit({
    required this.specializationId,
    required this.specializationName,
    required this.courseId,
    required this.courseName,
    required this.status,
    required this.lessonCount,
    required this.projectCount,
    required this.knowledgeUnitCount,
    required this.skillCount,
    required this.findings,
  });

  final String specializationId;
  final String specializationName;
  final String courseId;
  final String courseName;
  final AcademicBuildabilityStatus status;
  final int lessonCount;
  final int projectCount;
  final int knowledgeUnitCount;
  final int skillCount;
  final List<String> findings;

  bool get isBuildReady => status == AcademicBuildabilityStatus.complete;
}

class AcademicSpecializationBuildabilityAudit {
  const AcademicSpecializationBuildabilityAudit({
    required this.specializationId,
    required this.specializationName,
    required this.courseCount,
    required this.completeCourses,
    required this.partialCourses,
    required this.missingCourses,
    required this.findings,
  });

  final String specializationId;
  final String specializationName;
  final int courseCount;
  final int completeCourses;
  final int partialCourses;
  final int missingCourses;
  final List<String> findings;

  bool get isComplete =>
      courseCount > 0 &&
      completeCourses == courseCount &&
      partialCourses == 0 &&
      missingCourses == 0;
}

class AcademicLibraryBuildabilityAudit {
  const AcademicLibraryBuildabilityAudit._();

  static List<AcademicSpecializationBuildabilityAudit> run() => [
        for (final field in AcademicCatalog.fields)
          for (final university in field.universities)
            for (final college in university.colleges)
              for (final specialization in college.specializations)
                _auditSpecialization(specialization),
      ];

  static List<AcademicCourseBuildabilityAudit> courses() => [
        for (final specialization in _specializations())
          for (final year in specialization.years)
            for (final semester in year.semesters)
              for (final course in semester.courses)
                _auditCourse(specialization, course),
      ];

  static AcademicCourseBuildabilityAudit forCourse(String courseId) {
    for (final specialization in _specializations()) {
      for (final year in specialization.years) {
        for (final semester in year.semesters) {
          for (final course in semester.courses) {
            if (course.id == courseId) return _auditCourse(specialization, course);
          }
        }
      }
    }
    throw ArgumentError('Unknown academic course: \$courseId');
  }

  static AcademicSpecializationBuildabilityAudit _auditSpecialization(
    AcademicSpecialization specialization,
  ) {
    final audits = [
      for (final year in specialization.years)
        for (final semester in year.semesters)
          for (final course in semester.courses)
            _auditCourse(specialization, course),
    ];

    return AcademicSpecializationBuildabilityAudit(
      specializationId: specialization.id,
      specializationName: specialization.name,
      courseCount: audits.length,
      completeCourses: audits
          .where((item) => item.status == AcademicBuildabilityStatus.complete)
          .length,
      partialCourses: audits
          .where((item) => item.status == AcademicBuildabilityStatus.partial)
          .length,
      missingCourses: audits
          .where((item) => item.status == AcademicBuildabilityStatus.missing)
          .length,
      findings: {
        for (final audit in audits)
          ...audit.findings.map((finding) => '${audit.courseName}: $finding'),
      }.toList(growable: false),
    );
  }

  static AcademicCourseBuildabilityAudit _auditCourse(
    AcademicSpecialization specialization,
    AcademicCourse course,
  ) {
    final findings = <String>[];
    final lessons = course.lessons;
    final projects = [
      ...course.projects,
      ...lessons.expand((lesson) => lesson.projects),
    ];

    if (course.knowledgeAreaIds.isEmpty) {
      findings.add('المقرر بلا Knowledge Area.');
    }
    if (course.knowledgeUnitIds.isEmpty) {
      findings.add('المقرر بلا Knowledge Unit.');
    }
    if (lessons.isEmpty) findings.add('المقرر بلا دروس.');

    final weakLessons = lessons.where((lesson) {
      final hasPractice =
          lesson.practices.isNotEmpty &&
          lesson.practices.every((practice) => practice.tasks.isNotEmpty);
      final hasAssessment = lesson.assessments.isNotEmpty &&
          lesson.assessments.every((assessment) =>
              assessment.questions.isNotEmpty &&
              assessment.questions.every(
                (question) =>
                    question.learningOutcomeIndexes.isNotEmpty ||
                    question.conceptIds.isNotEmpty ||
                    question.skillIds.isNotEmpty,
              ));
      final hasOutcomes = lesson.learningOutcomes.isNotEmpty;
      final hasConcepts = lesson.conceptIds.isNotEmpty;
      final hasSkills = lesson.skillIds.isNotEmpty;
      final hasEvidence = lesson.skillEvidence.isNotEmpty;
      final hasProjectTrace = lesson.projects.isNotEmpty;
      return _isGenericFallbackLesson(lesson.title) ||
          !hasPractice ||
          !hasAssessment ||
          !hasOutcomes ||
          !hasConcepts ||
          !hasSkills ||
          !hasEvidence ||
          !hasProjectTrace;
    }).length;

    if (weakLessons > 0) {
      findings.add('يوجد $weakLessons درس/دروس تحتاج تعميقًا أو اعتمادًا تخصصيًا.');
    }

    if (course.curriculumProfile == null ||
        !course.curriculumProfile!.isValid) {
      findings.add('المقرر بلا بيانات وزن/تقديم أكاديمية صالحة.');
    }

    final allCourseIds = {
      for (final item in _allCourses()) item.id,
    };
    final danglingPrerequisites = course.prerequisiteCourseIds
        .where((id) => id == course.id || !allCourseIds.contains(id))
        .toList(growable: false);
    if (danglingPrerequisites.isNotEmpty) {
      findings.add('يوجد متطلب سابق غير صالح أو ذاتي: ' +
          danglingPrerequisites.join(', ') + '.');
    }

    if (_prerequisiteCycleCourseIds().contains(course.id)) {
      findings.add('المقرر داخل دورة في Prerequisite Graph ويحتاج تصحيح التسلسل الأكاديمي.');
    }

    final strongProjects = projects.where(_hasBuildContract).length;
    if (strongProjects == 0) {
      findings.add('لا يوجد مشروع يحمل عقد بناء قابلًا للتنفيذ والاختبار.');
    }

    final projectTraceWeak = projects.where((project) {
      return project.skillIds.isEmpty ||
          project.conceptIds.isEmpty ||
          project.recommendedToolCategories.isEmpty;
    }).length;
    if (projectTraceWeak > 0) {
      findings.add('يوجد $projectTraceWeak مشروع/مشاريع تحتاج ربطًا أوضح بالمفاهيم والمهارات والأدوات.');
    }
    final skillIds = {
      for (final lesson in lessons) ...lesson.skillIds,
      for (final project in projects) ...project.skillIds,
    };

    final status = findings.isEmpty && strongProjects > 0
        ? AcademicBuildabilityStatus.complete
        : (lessons.isEmpty && projects.isEmpty
            ? AcademicBuildabilityStatus.missing
            : AcademicBuildabilityStatus.partial);

    return AcademicCourseBuildabilityAudit(
      specializationId: specialization.id,
      specializationName: specialization.name,
      courseId: course.id,
      courseName: course.name,
      status: status,
      lessonCount: lessons.length,
      projectCount: projects.length,
      knowledgeUnitCount: course.knowledgeUnitIds.length,
      skillCount: skillIds.length,
      findings: findings,
    );
  }

  static bool _hasBuildContract(AcademicProject project) =>
      project.requirements.isNotEmpty &&
      project.deliverables.isNotEmpty &&
      project.milestones.isNotEmpty &&
      project.acceptanceCriteria.isNotEmpty &&
      project.implementationTasks.isNotEmpty &&
      project.testCases.isNotEmpty &&
      project.evidenceRequirements.isNotEmpty;

  static Set<String> _prerequisiteCycleCourseIds() {
    final courses = _allCourses().toList(growable: false);
    final byId = {for (final item in courses) item.id: item};
    final visiting = <String>{};
    final visited = <String>{};
    final cyclic = <String>{};

    void visit(String id, List<String> path) {
      if (visiting.contains(id)) {
        final start = path.indexOf(id);
        if (start >= 0) cyclic.addAll(path.sublist(start));
        return;
      }
      if (visited.contains(id)) return;
      final current = byId[id];
      if (current == null) return;
      visiting.add(id);
      for (final prerequisiteId in current.prerequisiteCourseIds) {
        if (byId.containsKey(prerequisiteId)) {
          visit(prerequisiteId, [...path, prerequisiteId]);
        }
      }
      visiting.remove(id);
      visited.add(id);
    }

    for (final course in courses) {
      visit(course.id, [course.id]);
    }
    return cyclic;
  }

  static Iterable<AcademicCourse> _allCourses() sync* {
    for (final specialization in _specializations()) {
      for (final year in specialization.years) {
        for (final semester in year.semesters) {
          yield* semester.courses;
        }
      }
    }
    yield* AcademicCatalog.foundationCourses;
  }

  static bool _isGenericFallbackLesson(String title) {
    const stages = [
      'الأساس المفاهيمي',
      'البنية والمكونات',
      'التطبيق الموجه',
      'التحليل والمقارنة',
      'التصميم والتحقق',
      'التكامل والمشروع',
    ];
    return stages.any(title.startsWith);
  }

  static Iterable<AcademicSpecialization> _specializations() sync* {
    for (final field in AcademicCatalog.fields) {
      for (final university in field.universities) {
        for (final college in university.colleges) {
          yield* college.specializations;
        }
      }
    }
  }
}
