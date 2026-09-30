import '../../domain/academic/academic_models.dart';
import 'academic_catalog.dart';

class AcademicLibraryAudit {
  const AcademicLibraryAudit._();

  static AcademicLibraryAuditReport run() {
    final issues = <String>[];
    var fields = 0, universities = 0, colleges = 0, specializations = 0;
    var years = 0, semesters = 0, courses = 0, lessons = 0;

    for (final field in AcademicCatalog.fields) {
      fields++;
      if (field.universities.isEmpty) issues.add('الحقل ${field.name} بلا جامعة مرجعية.');
      for (final university in field.universities) {
        universities++;
        if (university.colleges.isEmpty) issues.add('الجامعة ${university.name} بلا كلية أو مركز.');
        for (final college in university.colleges) {
          colleges++;
          for (final specialization in college.specializations) {
            specializations++;
            if (specialization.years.length != 4) {
              issues.add('التخصص ${specialization.name} يجب أن يحتوي 4 سنوات.');
            }
            for (final year in specialization.years) {
              years++;
              if (year.semesters.length != 2) {
                issues.add('السنة ${year.number} في ${specialization.name} يجب أن تحتوي فصلين.');
              }
              for (final semester in year.semesters) {
                semesters++;
                for (final course in semester.courses) {
                  courses++;
                  if (course.lessons.isEmpty) issues.add('المقرر ${course.name} بلا دروس.');
                  if (course.normalizedUnits.isEmpty) issues.add('المقرر ${course.name} بلا وحدات قابلة للتنفيذ.');
                  for (final lesson in course.lessons) {
                    lessons++;
                    _checkLesson(issues, lesson, course);
                  }
                }
              }
            }
          }
        }
      }
    }
    return AcademicLibraryAuditReport(
      fields: fields, universities: universities, colleges: colleges,
      specializations: specializations, years: years, semesters: semesters,
      courses: courses, lessons: lessons, issues: List.unmodifiable(issues),
    );
  }

  static void _checkLesson(List<String> issues, AcademicLesson lesson, AcademicCourse course) {
    if (lesson.content.trim().isEmpty) issues.add('الدرس ${lesson.title} في ${course.name} بلا محتوى.');
    if (lesson.learningOutcomes.isEmpty) issues.add('الدرس ${lesson.title} بلا نواتج تعلم.');
    if (lesson.keyTerms.isEmpty) issues.add('الدرس ${lesson.title} بلا مصطلحات.');
    if (lesson.examples.isEmpty) issues.add('الدرس ${lesson.title} بلا أمثلة.');
    if (lesson.practices.isEmpty) issues.add('الدرس ${lesson.title} بلا تدريب.');
    if (lesson.assessments.isEmpty) issues.add('الدرس ${lesson.title} بلا تقييم.');
    if (lesson.projects.isEmpty) issues.add('الدرس ${lesson.title} بلا مشروع.');
    for (final assessment in lesson.assessments) {
      if (assessment.questions.isEmpty) issues.add('تقييم ${assessment.title} في ${lesson.title} بلا أسئلة.');
      for (final question in assessment.questions) {
        if (question.options.length < 2 ||
            question.correctIndex < 0 ||
            question.correctIndex >= question.options.length) {
          issues.add('سؤال غير صالح ${question.id} في ${lesson.title}.');
        }
      }
    }
  }
}

class AcademicLibraryAuditReport {
  const AcademicLibraryAuditReport({
    required this.fields, required this.universities, required this.colleges,
    required this.specializations, required this.years, required this.semesters,
    required this.courses, required this.lessons, required this.issues,
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

  bool get isHealthy => issues.isEmpty;
}
