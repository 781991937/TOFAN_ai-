import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/academic/academic_catalog.dart';
import '../student/student_state.dart';

class LearningProgress {
  const LearningProgress({this.completedLessonIds = const []});

  final List<String> completedLessonIds;

  LearningProgress copyWith({List<String>? completedLessonIds}) {
    return LearningProgress(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }
}

final learningProgressProvider =
    NotifierProvider<LearningProgressController, LearningProgress>(
  LearningProgressController.new,
);

class LearningProgressController extends Notifier<LearningProgress> {
  @override
  LearningProgress build() => const LearningProgress();

  void completeLesson(String lessonId) {
    if (state.completedLessonIds.contains(lessonId)) return;
    state = state.copyWith(
      completedLessonIds: [...state.completedLessonIds, lessonId],
    );
  }

  bool isCompleted(String lessonId) =>
      state.completedLessonIds.contains(lessonId);

  double progressForCourse(String courseId) {
    final course = AcademicCatalog.referenceUniversity.colleges
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .where((item) => item.id == courseId)
        .firstOrNull;

    if (course == null || course.lessons.isEmpty) return 0;
    final completed = course.lessons
        .where((lesson) => isCompleted(lesson.id))
        .length;
    return completed / course.lessons.length;
  }

  double overallProgress() {
    final lessons = AcademicCatalog.referenceUniversity.colleges
        .expand((college) => college.specializations)
        .expand((specialization) => specialization.years)
        .expand((year) => year.semesters)
        .expand((semester) => semester.courses)
        .expand((course) => course.lessons)
        .toList(growable: false);
    if (lessons.isEmpty) return 0;
    final completed =
        lessons.where((lesson) => isCompleted(lesson.id)).length;
    return completed / lessons.length;
  }

  void clear() => state = const LearningProgress();
}
