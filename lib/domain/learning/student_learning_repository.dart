import 'student_learning_models.dart';

abstract interface class StudentLearningRepository {
  Future<void> save(String studentId, StudentLearningState state);
  Future<StudentLearningState?> load(String studentId);
  Future<void> clear(String studentId);
}
