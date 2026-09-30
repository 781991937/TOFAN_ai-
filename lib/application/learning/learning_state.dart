import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/academic/academic_catalog.dart';
import '../../domain/learning/learning_models.dart';
import 'skill_update_state.dart';
import '../../application/student/student_state.dart';
import 'progress_state.dart';

final learningSessionProvider =
    NotifierProvider<LearningSessionController, LearningSession?>(
  LearningSessionController.new,
);

class LearningSessionController extends Notifier<LearningSession?> {
  @override
  LearningSession? build() => null;

  void startLesson(String lessonId) {
    state = LearningSession(
      lessonId: lessonId,
      stage: LearningStage.study,
      startedAt: DateTime.now(),
    );
  }

  void completeStudy() {
    final session = state;
    if (session == null || session.isCompleted) return;
    state = LearningSession(
      lessonId: session.lessonId,
      stage: LearningStage.practice,
      startedAt: session.startedAt,
      completedAt: DateTime.now(),
    );
    ref.read(learningProgressProvider.notifier).completeLesson(session.lessonId);
  }

  void completePractice() {
    final session = state;
    if (session == null || session.stage != LearningStage.practice) return;
    state = LearningSession(
      lessonId: session.lessonId,
      stage: LearningStage.assessment,
      startedAt: session.startedAt,
    );
  }

  void startAssessment() {
    final session = state;
    if (session == null || session.stage != LearningStage.assessment) return;
    state = LearningSession(
      lessonId: session.lessonId,
      stage: LearningStage.assessment,
      startedAt: session.startedAt,
    );
  }

  void completeAssessment() {
    final session = state;
    if (session == null || session.stage != LearningStage.assessment) return;
    state = LearningSession(
      lessonId: session.lessonId,
      stage: LearningStage.analysis,
      startedAt: session.startedAt,
    );
  }

  void completeAnalysis() {
    final session = state;
    if (session == null || session.stage != LearningStage.analysis) return;
    state = LearningSession(
      lessonId: session.lessonId,
      stage: LearningStage.skillUpdate,
      startedAt: session.startedAt,
    );
  }

  void completeSkillUpdate() {
    final session = state;
    if (session == null || session.stage != LearningStage.skillUpdate) return;
    state = LearningSession(
      lessonId: session.lessonId,
      stage: LearningStage.project,
      startedAt: session.startedAt,
    );
  }

  void enterProject() {
    final session = state;
    if (session == null || session.stage != LearningStage.project) return;
    state = LearningSession(
      lessonId: session.lessonId,
      stage: LearningStage.project,
      startedAt: session.startedAt,
    );
  }

  void clear() => state = null;
}

final learningPlanProvider =
    NotifierProvider<LearningPlanController, LearningPlan?>(
  LearningPlanController.new,
);

class LearningPlanController extends Notifier<LearningPlan?> {
  @override
  LearningPlan? build() {
    final student = ref.watch(studentProfileProvider);
    if (student == null) return null;

    final courses =
        _currentCourses(student.specialization, student.currentYear, student.currentSemester);

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

  List<AcademicCourse> _currentCourses(
    String specializationName,
    int yearNumber,
    int semesterNumber,
  ) {
    final specializations = AcademicCatalog.referenceUniversity.colleges
        .expand((college) => college.specializations)
        .toList(growable: false);

    if (specializations.isEmpty) return const <AcademicCourse>[];

    final specialization = specializations.firstWhere(
      (item) =>
          item.id == specializationName || item.name == specializationName,
      orElse: () => specializations.first,
    );

    if (specialization.years.isEmpty) return const <AcademicCourse>[];

    final year = specialization.years.firstWhere(
      (item) => item.number == yearNumber,
      orElse: () => specialization.years.first,
    );

    if (year.semesters.isEmpty) return const <AcademicCourse>[];

    final semester = year.semesters.firstWhere(
      (item) => item.number == semesterNumber,
      orElse: () => year.semesters.first,
    );

    return semester.courses;
  }
}
