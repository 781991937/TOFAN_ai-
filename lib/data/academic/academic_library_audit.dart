import '../../domain/academic/academic_models.dart';
import 'academic_catalog.dart';
import 'academic_knowledge_area_catalog.dart';
import 'academic_knowledge_unit_catalog.dart';
import 'academic_library_security_catalog.dart';

/// Structural and instructional integrity gate for the TOFAN Academic Library.
class AcademicLibraryAudit {
  const AcademicLibraryAudit._();

  static AcademicLibraryAuditReport run() {
    final issues = <String>[];
    var fields = 0, universities = 0, colleges = 0, specializations = 0;
    var years = 0, semesters = 0, courses = 0, lessons = 0;
    final fieldIds = <String>{};
    final universityIds = <String>{};
    final collegeIds = <String>{};
    final specializationIds = <String>{};
    final courseIds = <String>{};
    final lessonIds = <String>{};
    final conceptIds = <String>{};
    final skillIds = <String>{};
    final allCourses = <AcademicCourse>[];
    final knowledgeAreas = <String>{};
    final knownKnowledgeAreas = AcademicKnowledgeAreaCatalog.areas
        .map((area) => area.id)
        .toSet();
    final knownKnowledgeUnits = AcademicKnowledgeUnitCatalog.units
        .map((unit) => unit.id)
        .toSet();
    final knowledgeUnitIds = <String>{};
    final curriculumMetadataGaps = <String>[];

    for (final field in AcademicCatalog.fields) {
      fields++;
      if (!fieldIds.add(field.id)) issues.add('معرف الحقل مكرر: ${field.id}.');
      if (field.universities.isEmpty) issues.add('الحقل ${field.name} بلا جامعة مرجعية.');

      for (final university in field.universities) {
        universities++;
        if (!universityIds.add(university.id)) issues.add('معرف الجامعة مكرر: ${university.id}.');
        if (university.colleges.isEmpty) issues.add('الجامعة ${university.name} بلا كلية أو مركز.');

        for (final college in university.colleges) {
          colleges++;
          if (!collegeIds.add(college.id)) issues.add('معرف الكلية أو المركز مكرر: ${college.id}.');

          for (final specialization in college.specializations) {
            specializations++;
            if (!specializationIds.add(specialization.id)) issues.add('معرف التخصص مكرر: ${specialization.id}.');
            if (specialization.years.length != 4) issues.add('التخصص ${specialization.name} يجب أن يحتوي 4 سنوات.');

            for (final year in specialization.years) {
              years++;
              if (year.semesters.length != 2) {
                issues.add('السنة ${year.number} في ${specialization.name} يجب أن تحتوي فصلين.');
              }

              for (final semester in year.semesters) {
                semesters++;
                for (final course in semester.courses) {
                  courses++;
                  allCourses.add(course);
                  if (course.curriculumProfile == null) {
                    curriculumMetadataGaps.add('المقرر ${course.name} بلا وزن أكاديمي (credits/contact hours).');
                  } else if (!course.curriculumProfile!.isValid) {
                    issues.add('بيانات الوزن الأكاديمي غير صالحة في ${course.name}.');
                  }
                  if (course.provenance.status != AcademicPublicationStatus.draft &&
                      course.provenance.status != AcademicPublicationStatus.privateContent &&
                      !course.provenance.hasSource) {
                    issues.add('المقرر المنشور/المراجع ${course.name} بلا مصدر مرجعي.');
                  }
                  if (course.knowledgeAreaIds.isEmpty) {
                    issues.add('المقرر ${course.name} بلا تصنيف معرفي CS2023.');
                  }
                  for (final area in course.knowledgeAreaIds) {
                    knowledgeAreas.add(area);
                    if (!knownKnowledgeAreas.contains(area)) {
                      issues.add('المقرر ${course.name} يستخدم مجالًا معرفيًا غير معروف: ${area}.');
                    }
                  }
                  if (course.knowledgeUnitIds.isEmpty) {
                    issues.add('المقرر ${course.name} بلا وحدات معرفية دقيقة.');
                  }
                  final courseUnitSet = <String>{};
                  for (final unitId in course.knowledgeUnitIds) {
                    if (!courseUnitSet.add(unitId)) {
                      issues.add('الوحدة المعرفية مكررة داخل ${course.name}: $unitId.');
                    }
                    if (!knownKnowledgeUnits.contains(unitId)) {
                      issues.add('المقرر ${course.name} يستخدم وحدة معرفية غير معروفة: $unitId.');
                    } else {
                      knowledgeUnitIds.add(unitId);
                      final unit = AcademicKnowledgeUnitCatalog.byId(unitId);
                      if (unit != null && !course.knowledgeAreaIds.contains(unit.areaId)) {
                        issues.add('الوحدة $unitId في ${course.name} لا تنتمي إلى أحد مجالات المقرر.');
                      }
                    }
                  }
                  if (!courseIds.add(course.id)) issues.add('معرف المقرر مكرر: ${course.id}.');
                  if (course.lessons.isEmpty) issues.add('المقرر ${course.name} بلا دروس.');
                  if (course.normalizedUnits.isEmpty) issues.add('المقرر ${course.name} بلا وحدات قابلة للتنفيذ.');

                  final unitIds = <String>{};
                  final unitLessonIds = <String>[];
                  for (final unit in course.normalizedUnits) {
                    if (!unitIds.add(unit.id)) issues.add('معرف الوحدة مكرر داخل ${course.name}: ${unit.id}.');
                    for (final unitLesson in unit.lessons) unitLessonIds.add(unitLesson.id);
                  }
                  final courseLessonIds = course.lessons.map((lesson) => lesson.id).toSet();
                  if (unitLessonIds.length != courseLessonIds.length ||
                      unitLessonIds.toSet().length != unitLessonIds.length ||
                      !unitLessonIds.toSet().containsAll(courseLessonIds)) {
                    issues.add('وحدات المقرر ${course.name} لا تمثل دروسه مرة واحدة وبصورة كاملة.');
                  }

                  for (final prerequisiteId in course.prerequisiteCourseIds) {
                    if (prerequisiteId == course.id) issues.add('المقرر ${course.name} يعتمد على نفسه.');
                  }

                  for (final lesson in course.lessons) {
                    lessons++;
                    if (!lessonIds.add(lesson.id)) issues.add('معرف الدرس مكرر: ${lesson.id}.');
                    for (final conceptId in lesson.conceptIds) {
                      if (!conceptIds.add(conceptId)) issues.add('معرف المفهوم مكرر: ${conceptId}.');
                    }
                    for (final skillId in lesson.skillIds) {
                      if (!skillIds.add(skillId)) issues.add('معرف المهارة مكرر: ${skillId}.');
                    }
                    _checkLesson(issues, curriculumMetadataGaps, lesson, course);
                  }
                }
              }
            }
          }
        }
      }
    }

    _checkPrerequisites(issues, allCourses);
    final securityReport = AcademicLibrarySecurityAudit.run();
    issues.addAll(securityReport.issues.map((issue) => 'أمن المكتبة: $issue'));

    final missingAreas = knownKnowledgeAreas.difference(knowledgeAreas);
    if (missingAreas.isNotEmpty) {
      issues.add('مجالات CS2023 غير المغطاة في المكتبة: ${missingAreas.join(', ')}.');
    }
    return AcademicLibraryAuditReport(
      fields: fields,
      universities: universities,
      colleges: colleges,
      specializations: specializations,
      years: years,
      semesters: semesters,
      courses: courses,
      lessons: lessons,
      issues: List.unmodifiable(issues),
      curriculumMetadataGaps: List.unmodifiable(curriculumMetadataGaps),
    );
  }

  static void _checkLesson(
    List<String> issues,
    List<String> curriculumMetadataGaps,
    AcademicLesson lesson,
    AcademicCourse course,
  ) {
    final context = '${lesson.title} في ${course.name}';
    if (lesson.provenance.status == AcademicPublicationStatus.published && !lesson.provenance.hasSource) {
      issues.add('الدرس المنشور $context بلا مصدر مرجعي.');
    } else if (!lesson.provenance.hasSource) {
      curriculumMetadataGaps.add('الدرس $context يحتاج provenance ومصدرًا قبل النشر.');
    }
    if (lesson.provenance.isReviewable && lesson.provenance.reviewer == null) {
      issues.add('الدرس المراجع $context بلا مراجع محدد.');
    }
    if (lesson.content.trim().isEmpty) issues.add('الدرس $context بلا محتوى.');
    if (lesson.definition.trim().isEmpty) issues.add('الدرس $context بلا تعريف صريح.');
    if (lesson.learningOutcomes.isEmpty) issues.add('الدرس $context بلا نواتج تعلم.');
    if (lesson.keyTerms.isEmpty) issues.add('الدرس $context بلا مصطلحات.');
    if (lesson.examples.isEmpty) issues.add('الدرس $context بلا أمثلة.');
    if (lesson.applications.isEmpty) issues.add('الدرس $context بلا تطبيقات.');
    if (lesson.practices.isEmpty) issues.add('الدرس $context بلا تدريب.');
    if (lesson.assessments.isEmpty) issues.add('الدرس $context بلا تقييم.');
    if (lesson.errorAnalysisGuidance.trim().isEmpty) issues.add('الدرس $context بلا إرشاد لتحليل الأخطاء.');
    if (lesson.skillEvidence.isEmpty) issues.add('الدرس $context بلا دليل قابل للملاحظة على اكتساب المهارة.');
    if (lesson.projects.isEmpty) issues.add('الدرس $context بلا مشروع.');
    if (lesson.conceptIds.isEmpty) issues.add('الدرس $context بلا معرف مفهوم.');
    if (lesson.skillIds.isEmpty) issues.add('الدرس $context بلا معرف مهارة.');

    for (final practice in lesson.practices) {
      if (practice.tasks.length < 2) issues.add('التدريب ${practice.title} في $context غير متدرج بما يكفي.');
    }

    for (final assessment in lesson.assessments) {
      if (assessment.questions.length < 3) issues.add('تقييم ${assessment.title} في $context يحتاج 3 أسئلة على الأقل.');
      final answerPositions = <int>{};
      for (final question in assessment.questions) {
        if (question.options.length < 2 ||
            question.correctIndex < 0 ||
            question.correctIndex >= question.options.length) {
          issues.add('سؤال غير صالح ${question.id} في $context.');
        }
        answerPositions.add(question.correctIndex);
        if (question.learningOutcomeIndexes.isEmpty) {
          issues.add('السؤال ${question.id} في $context غير مرتبط بناتج تعلم.');
        }
        for (final outcomeIndex in question.learningOutcomeIndexes) {
          if (outcomeIndex < 0 || outcomeIndex >= lesson.learningOutcomes.length) {
            issues.add('السؤال ${question.id} في $context يشير إلى ناتج تعلم غير موجود.');
          }
        }
        if (question.conceptIds.isEmpty || !lesson.conceptIds.toSet().containsAll(question.conceptIds)) {
          issues.add('السؤال ${question.id} في $context غير مرتبط بمفاهيم الدرس بصورة صحيحة.');
        }
        if (question.skillIds.isEmpty || !lesson.skillIds.toSet().containsAll(question.skillIds)) {
          issues.add('السؤال ${question.id} في $context غير مرتبط بمهارات الدرس بصورة صحيحة.');
        }
      }
      if (assessment.questions.length >= 3 && answerPositions.length < 2) {
        issues.add('تقييم ${assessment.title} في $context يضع الإجابات الصحيحة في موضع واحد فقط.');
      }
    }

    for (final project in lesson.projects) {
      if (project.description.trim().isEmpty) issues.add('المشروع ${project.title} في $context بلا وصف.');
      if (project.conceptIds.isEmpty || !lesson.conceptIds.toSet().containsAll(project.conceptIds)) {
        issues.add('المشروع ${project.title} في $context غير مرتبط بمفاهيم الدرس.');
      }
      if (project.skillIds.isEmpty || !lesson.skillIds.toSet().containsAll(project.skillIds)) {
        issues.add('المشروع ${project.title} في $context غير مرتبط بمهارات الدرس.');
      }
    }
  }

  static void _checkPrerequisites(List<String> issues, List<AcademicCourse> courses) {
    final byId = <String, AcademicCourse>{for (final course in courses) course.id: course};
    for (final course in courses) {
      for (final prerequisiteId in course.prerequisiteCourseIds) {
        if (!byId.containsKey(prerequisiteId)) {
          issues.add('المتطلب السابق $prerequisiteId للمقرر ${course.name} غير موجود في المكتبة.');
        }
      }
    }

    final visiting = <String>{};
    final visited = <String>{};
    bool visit(String id) {
      if (visiting.contains(id)) return false;
      if (visited.contains(id)) return true;
      visiting.add(id);
      final course = byId[id];
      if (course != null) {
        for (final prerequisiteId in course.prerequisiteCourseIds) {
          if (!visit(prerequisiteId)) return false;
        }
      }
      visiting.remove(id);
      visited.add(id);
      return true;
    }

    for (final course in courses) {
      if (!visit(course.id)) {
        issues.add('دورة اعتماد دائرية في المتطلبات السابقة تبدأ عند ${course.name}.');
        break;
      }
    }
  }
}

class AcademicLibraryAuditReport {
  const AcademicLibraryAuditReport({
    required this.fields,
    required this.universities,
    required this.colleges,
    required this.specializations,
    required this.years,
    required this.semesters,
    required this.courses,
    required this.lessons,
    required this.issues,
    required this.curriculumMetadataGaps,
  });
  final int fields;
  final int universities;
  final int colleges;
  final int specializations;
  final int years;
  final int semesters;
  final int courses;
  final int lessons;
  final List<String> issues;
  /// Metadata gaps do not invalidate structural integrity, but block production readiness.
  final List<String> curriculumMetadataGaps;
  bool get isHealthy => issues.isEmpty;
  bool get isCurriculumReady => isHealthy && curriculumMetadataGaps.isEmpty;
}
