import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/learning/analysis_models.dart';
import '../../domain/learning/student_learning_models.dart';
import '../../domain/student/student_models.dart';
import '../../providers/security_provider.dart';

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
  Future<void>? _hydration;

  @override
  StudentLearningState build() {
    // Hydration starts as soon as the authenticated learning state is first
    // observed. Callers can await reload() when they need a synchronization
    // barrier before rendering or evaluating the student.
    unawaited(_safeReload());
    return const StudentLearningState();
  }

  Future<void> _safeReload() async {
    try {
      await reload();
    } catch (_) {
      // A non-configured or signed-out client starts with an empty state.
      // Explicit callers can use reload() to receive the original failure.
    }
  }

  /// Reloads the authenticated student's durable state into memory.
  Future<void> reload() {
    return _hydration ??= _reload().whenComplete(() => _hydration = null);
  }

  Future<void> _reload() async {
    final studentId = await _authenticatedStudentId();
    if (studentId == null) return;
    final loaded = await ref
        .read(studentLearningRepositoryProvider)
        .load(studentId);
    if (loaded != null) state = loaded;
  }

  /// Persists the current in-memory state for the authenticated student.
  Future<void> save() async {
    final studentId = await _authenticatedStudentId();
    if (studentId == null) {
      throw StateError('An active authenticated student is required.');
    }
    await ref.read(studentLearningRepositoryProvider).save(studentId, state);
  }

  Future<String?> _authenticatedStudentId() async {
    final session = await ref
        .read(authenticationGatewayProvider)
        .currentSession();
    if (session == null || !session.isActive) return null;
    final actorId = session.identity.actorId.trim();
    return actorId.isEmpty ? null : actorId;
  }

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

    // Preserve the existing synchronous domain API while ensuring the normal
    // application path attempts durable persistence immediately.
    unawaited(_persistAfterMutation());
  }

  Future<void> _persistAfterMutation() async {
    try {
      await save();
    } catch (_) {
      // Explicit callers can await save() and receive the failure. The UI
      // mutation remains valid in memory when persistence is unavailable.
    }
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

  Future<void> clear() async {
    final studentId = await _authenticatedStudentId();
    if (studentId != null) {
      await ref.read(studentLearningRepositoryProvider).clear(studentId);
    }
    state = const StudentLearningState();
  }
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
