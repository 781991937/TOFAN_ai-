import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/academic/academic_catalog.dart';
import '../../domain/learning/learning_models.dart';
import '../student/student_state.dart';

final learningPlanProvider =
    NotifierProvider<LearningPlanController, LearningPlan?>(
  LearningPlanController.new,
);

class LearningPlanController extends Notifier<LearningPlan?> {
  @override
  LearningPlan? build() {
    final student = ref.watch(studentProfileProvider);
    if (student == null) return null;

    final courses = _currentCourses(student.currentYear, student.currentSemester);
    return LearningPlan(
      id: 'plan-${const Uuid().v4()}',
      studentName: student.name,
      specialization: student.specialization,
      currentYear: student.currentYear,
      currentSemester: student.currentSemester,
      courseIds: courses.map((course) => course.id).toList(growable: false),
    );
  }

  void moveToNextCourse() {
    final plan = state;
    if (plan == null) return;
    if (plan.currentCourseIndex + 1 >= plan.courseIds.length) return;

    state = plan.copyWith(currentCourseIndex: plan.currentCourseIndex + 1);
  }

  List<AcademicCourse> _currentCourses(int yearNumber, int semesterNumber) {
    final specialization = AcademicCatalog.referenceUniversity.colleges
        .expand((college) => college.specializations)
        .firstWhere(
          (specialization) => specialization.id == 'ai',
          orElse: () => AcademicCatalog.referenceUniversity.colleges
              .expand((college) => college.specializations)
              .first,
        );

    final year = specialization.years.firstWhere(
      (year) => year.number == yearNumber,
      orElse: () => specialization.years.first,
    );

    final semester = year.semesters.firstWhere(
      (semester) => semester.number == semesterNumber,
      orElse: () => year.semesters.first,
    );

    return semester.courses;
  }
}
