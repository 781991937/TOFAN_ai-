import '../academic/academic_models.dart';

enum LearningStage {
  diagnostic,
  learningPlan,
  study,
  practice,
  assessment,
  analysis,
  skillUpdate,
  project,
}

class LearningPlan {
  const LearningPlan({
    required this.id,
    required this.studentName,
    required this.specialization,
    required this.currentYear,
    required this.currentSemester,
    required this.courseIds,
    this.currentCourseIndex = 0,
  });

  final String id;
  final String studentName;
  final String specialization;
  final int currentYear;
  final int currentSemester;
  final List<String> courseIds;
  final int currentCourseIndex;

  String? get currentCourseId =>
      courseIds.isEmpty || currentCourseIndex >= courseIds.length
          ? null
          : courseIds[currentCourseIndex];

  LearningPlan copyWith({
    String? id,
    String? studentName,
    String? specialization,
    int? currentYear,
    int? currentSemester,
    List<String>? courseIds,
    int? currentCourseIndex,
  }) {
    return LearningPlan(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      specialization: specialization ?? this.specialization,
      currentYear: currentYear ?? this.currentYear,
      currentSemester: currentSemester ?? this.currentSemester,
      courseIds: courseIds ?? this.courseIds,
      currentCourseIndex: currentCourseIndex ?? this.currentCourseIndex,
    );
  }
}

class LearningSession {
  const LearningSession({
    required this.lessonId,
    required this.stage,
    required this.startedAt,
    this.completedAt,
  });

  final String lessonId;
  final LearningStage stage;
  final DateTime startedAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
}

class AssessmentResult {
  const AssessmentResult({
    required this.assessmentId,
    required this.score,
    required this.total,
    required this.completedAt,
  });

  final String assessmentId;
  final double score;
  final double total;
  final DateTime completedAt;

  double get percentage =>
      total <= 0 ? 0 : (score / total * 100).clamp(0.0, 100.0).toDouble();

  bool get passed => percentage >= 60;
}

/// Builds a deterministic first learning plan from the existing academic catalog.
LearningPlan buildInitialLearningPlan({
  required StudentProfileLike student,
  required List<AcademicCourse> courses,
}) {
  final courseIds = courses.map((course) => course.id).toList(growable: false);
  return LearningPlan(
    id: 'plan-${student.name.hashCode.abs()}',
    studentName: student.name,
    specialization: student.specialization,
    currentYear: student.currentYear,
    currentSemester: student.currentSemester,
    courseIds: courseIds,
  );
}

/// Small contract used to avoid coupling the learning domain to a UI state class.
abstract class StudentProfileLike {
  String get name;
  String get specialization;
  int get currentYear;
  int get currentSemester;
}
