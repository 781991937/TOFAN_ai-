import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/academic/academic_catalog.dart';

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

  AcademicCourse? _findCourse(String courseId) {
    for (final field in AcademicCatalog.fields) {
      for (final university in field.universities) {
        for (final college in university.colleges) {
          for (final specialization in college.specializations) {
            for (final year in specialization.years) {
              for (final semester in year.semesters) {
                for (final course in semester.courses) {
                  if (course.id == courseId) return course;
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

  Iterable<AcademicLesson> _allLessons() sync* {
    for (final field in AcademicCatalog.fields) {
      for (final university in field.universities) {
        for (final college in university.colleges) {
          for (final specialization in college.specializations) {
            for (final year in specialization.years) {
              for (final semester in year.semesters) {
                for (final course in semester.courses) {
                  yield* course.lessons;
                }
              }
            }
          }
        }
      }
    }
  }

  double progressForCourse(String courseId) {
    final course = _findCourse(courseId);
    if (course == null || course.lessons.isEmpty) return 0;

    final completed = course.lessons
        .where((lesson) => isCompleted(lesson.id))
        .length;
    return completed / course.lessons.length;
  }

  double overallProgress() {
    final lessons = _allLessons().toList(growable: false);
    if (lessons.isEmpty) return 0;

    final completed =
        lessons.where((lesson) => isCompleted(lesson.id)).length;
    return completed / lessons.length;
  }

  void clear() => state = const LearningProgress();
}
