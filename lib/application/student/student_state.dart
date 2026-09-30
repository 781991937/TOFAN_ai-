import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/student/student_models.dart';

final studentProfileProvider = StateProvider<StudentProfile?>((ref) => null);

final smartStudentProvider =
    NotifierProvider<SmartStudentController, SmartStudentState>(
  SmartStudentController.new,
);

class SmartStudentController extends Notifier<SmartStudentState> {
  @override
  SmartStudentState build() => const SmartStudentState();

  void recordLearning({
    double knowledgeDelta = 0.0,
    double skillDelta = 0.0,
    double capabilityDelta = 0.0,
  }) {
    state = state.copyWith(
      knowledgeLevel: _bounded(state.knowledgeLevel + knowledgeDelta),
      skillLevel: _bounded(state.skillLevel + skillDelta),
      capabilityLevel: _bounded(state.capabilityLevel + capabilityDelta),
      learningStreak: state.learningStreak + 1,
    );
  }

  void setDiagnosticLevels({
    required double knowledgeLevel,
    required double skillLevel,
    required double capabilityLevel,
  }) {
    state = state.copyWith(
      knowledgeLevel: _bounded(knowledgeLevel),
      skillLevel: _bounded(skillLevel),
      capabilityLevel: _bounded(capabilityLevel),
    );
  }

  double _bounded(double value) => value.clamp(0.0, 100.0).toDouble();
}
