import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/student/student_models.dart';
import '../../domain/learning/student_learning_models.dart';
import '../../domain/learning/analysis_models.dart';

final studentProfileProvider = StateProvider<StudentProfile?>((ref) => null);

final smartStudentProvider =
    NotifierProvider<SmartStudentController, SmartStudentState>(
  SmartStudentController.new,
);

final studentLearningStateProvider =
    NotifierProvider<StudentLearningStateController, StudentLearningState>(
  StudentLearningStateController.new,
);

class StudentLearningStateController extends Notifier<StudentLearningState> {
  @override
  StudentLearningState build() => const StudentLearningState();

  void recordKnowledge({
    required String sourceId,
    required String sourceType,
    required List<String> conceptIds,
    required List<String> skillIds,
    required List<String> capabilityIds,
    double knowledgeLevel = 0,
    double skillLevel = 0,
  }) {
    final now = DateTime.now();
    final concepts = {...state.concepts};
    for (final id in conceptIds) {
      final current = concepts[id];
      concepts[id] = ConceptState(
        conceptId: id,
        knowledgeLevel: _bounded(current?.knowledgeLevel ?? 0, knowledgeLevel),
        lastUpdated: now,
      );
    }
    final skills = {...state.skills};
    for (final id in skillIds) {
      final current = skills[id];
      final level = _bounded(current?.level ?? 0, skillLevel);
      skills[id] = SkillState(
        skillId: id,
        level: level,
        status: level >= 80
            ? StudentSkillStatus.acquired
            : level >= 60
                ? StudentSkillStatus.developing
                : StudentSkillStatus.missing,
        lastUpdated: now,
      );
    }
    final capabilities = {...state.capabilities};
    for (final id in capabilityIds) {
      capabilities[id] = CapabilityState(
        capabilityId: id,
        verified: capabilities[id]?.verified ?? false,
        lastUpdated: now,
      );
    }
    state = StudentLearningState(
      concepts: Map.unmodifiable(concepts),
      skills: Map.unmodifiable(skills),
      capabilities: Map.unmodifiable(capabilities),
      history: List.unmodifiable([
        ...state.history,
        LearningHistoryEntry(
          sourceId: sourceId,
          sourceType: sourceType,
          at: now,
          conceptIds: List.unmodifiable(conceptIds),
          skillIds: List.unmodifiable(skillIds),
          capabilityIds: List.unmodifiable(capabilityIds),
        ),
      ]),
    );
  }

  double _bounded(double current, double delta) =>
      (current + delta).clamp(0.0, 100.0).toDouble();

  void recordAssessmentAnalysis({
    required LearningAnalysis analysis,
    required String sourceId,
  }) {
    recordKnowledge(
      sourceId: sourceId,
      sourceType: 'assessment_analysis',
      conceptIds: analysis.conceptGapIds,
      skillIds: analysis.skillGapIds,
      capabilityIds: const [],
      knowledgeLevel: analysis.knowledgeDelta,
      skillLevel: analysis.skillDelta,
    );
  }

  void clear() => state = const StudentLearningState();
}

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
