import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/learning/student_learning_models.dart';
import '../../domain/learning/student_learning_repository.dart';

class SupabaseStudentLearningRepository implements StudentLearningRepository {
  SupabaseStudentLearningRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String _requireCurrentUser(String studentId) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('An active Supabase user is required.');
    }
    if (studentId != userId) {
      throw StateError('Student identity does not match the authenticated user.');
    }
    return userId;
  }

  @override
  Future<void> save(String studentId, StudentLearningState state) async {
    final id = _requireCurrentUser(studentId);
    await _client.from('student_learning_state').upsert({
      'student_id': id,
      'payload': _toJson(state),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<StudentLearningState?> load(String studentId) async {
    final id = _requireCurrentUser(studentId);
    final row = await _client
        .from('student_learning_state')
        .select('payload')
        .eq('student_id', id)
        .maybeSingle();
    if (row == null) return null;
    return _fromJson(Map<String, dynamic>.from(row['payload'] as Map));
  }

  @override
  Future<void> clear(String studentId) async {
    final id = _requireCurrentUser(studentId);
    await _client.from('student_learning_state').delete().eq('student_id', id);
  }

  Map<String, dynamic> _toJson(StudentLearningState state) => {
        'concepts': state.concepts.values
            .map((item) => {
                  'conceptId': item.conceptId,
                  'knowledgeLevel': item.knowledgeLevel,
                  'lastUpdated': item.lastUpdated?.millisecondsSinceEpoch,
                })
            .toList(),
        'skills': state.skills.values
            .map((item) => {
                  'skillId': item.skillId,
                  'level': item.level,
                  'status': item.status.name,
                  'lastUpdated': item.lastUpdated?.millisecondsSinceEpoch,
                })
            .toList(),
        'capabilities': state.capabilities.values
            .map((item) => {
                  'capabilityId': item.capabilityId,
                  'verified': item.verified,
                  'lastUpdated': item.lastUpdated?.millisecondsSinceEpoch,
                })
            .toList(),
        'history': state.history
            .map((item) => {
                  'sourceId': item.sourceId,
                  'sourceType': item.sourceType,
                  'at': item.at.millisecondsSinceEpoch,
                  'conceptIds': item.conceptIds,
                  'skillIds': item.skillIds,
                  'capabilityIds': item.capabilityIds,
                })
            .toList(),
      };

  StudentLearningState _fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) =>
        value is num ? DateTime.fromMillisecondsSinceEpoch(value.toInt()) : null;

    final concepts = <String, ConceptState>{};
    for (final raw in (json['concepts'] as List<dynamic>? ?? const [])) {
      final item = Map<String, dynamic>.from(raw as Map);
      final value = ConceptState(
        conceptId: item['conceptId'] as String,
        knowledgeLevel: (item['knowledgeLevel'] as num?)?.toDouble() ?? 0,
        lastUpdated: date(item['lastUpdated']),
      );
      concepts[value.conceptId] = value;
    }

    final skills = <String, SkillState>{};
    for (final raw in (json['skills'] as List<dynamic>? ?? const [])) {
      final item = Map<String, dynamic>.from(raw as Map);
      final status = StudentSkillStatus.values.firstWhere(
        (value) => value.name == (item['status'] as String? ?? 'missing'),
        orElse: () => StudentSkillStatus.missing,
      );
      final value = SkillState(
        skillId: item['skillId'] as String,
        level: (item['level'] as num?)?.toDouble() ?? 0,
        status: status,
        lastUpdated: date(item['lastUpdated']),
      );
      skills[value.skillId] = value;
    }

    final capabilities = <String, CapabilityState>{};
    for (final raw in (json['capabilities'] as List<dynamic>? ?? const [])) {
      final item = Map<String, dynamic>.from(raw as Map);
      final value = CapabilityState(
        capabilityId: item['capabilityId'] as String,
        verified: item['verified'] as bool? ?? false,
        lastUpdated: date(item['lastUpdated']),
      );
      capabilities[value.capabilityId] = value;
    }

    final history = <LearningHistoryEntry>[];
    for (final raw in (json['history'] as List<dynamic>? ?? const [])) {
      final item = Map<String, dynamic>.from(raw as Map);
      final at = item['at'];
      if (at is! num) continue;
      history.add(LearningHistoryEntry(
        sourceId: item['sourceId'] as String,
        sourceType: item['sourceType'] as String,
        at: DateTime.fromMillisecondsSinceEpoch(at.toInt()),
        conceptIds: List<String>.from(item['conceptIds'] as List? ?? const []),
        skillIds: List<String>.from(item['skillIds'] as List? ?? const []),
        capabilityIds:
            List<String>.from(item['capabilityIds'] as List? ?? const []),
      ));
    }

    return StudentLearningState(
      concepts: Map.unmodifiable(concepts),
      skills: Map.unmodifiable(skills),
      capabilities: Map.unmodifiable(capabilities),
      history: List.unmodifiable(history),
    );
  }
}
