import 'dart:convert';

import '../../database/app_database.dart';
import '../../domain/learning/student_learning_models.dart';
import '../../domain/learning/student_learning_repository.dart';

class SqliteStudentLearningRepository implements StudentLearningRepository {
  SqliteStudentLearningRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<void> save(String studentId, StudentLearningState state) {
    return _database.saveStudentLearningState(
      studentId,
      jsonEncode(_toJson(state)),
    );
  }

  @override
  Future<StudentLearningState?> load(String studentId) async {
    final payload = await _database.loadStudentLearningState(studentId);
    if (payload == null) return null;
    return _fromJson(jsonDecode(payload) as Map<String, dynamic>);
  }

  @override
  Future<void> clear(String studentId) =>
      _database.clearStudentLearningState(studentId);

  Map<String, dynamic> _toJson(StudentLearningState state) => {
        'concepts': state.concepts.values.map((item) => {
              'conceptId': item.conceptId,
              'knowledgeLevel': item.knowledgeLevel,
              'lastUpdated': item.lastUpdated?.millisecondsSinceEpoch,
            }).toList(),
        'skills': state.skills.values.map((item) => {
              'skillId': item.skillId,
              'level': item.level,
              'status': item.status.name,
              'lastUpdated': item.lastUpdated?.millisecondsSinceEpoch,
            }).toList(),
        'capabilities': state.capabilities.values.map((item) => {
              'capabilityId': item.capabilityId,
              'verified': item.verified,
              'lastUpdated': item.lastUpdated?.millisecondsSinceEpoch,
            }).toList(),
        'history': state.history.map((item) => {
              'sourceId': item.sourceId,
              'sourceType': item.sourceType,
              'at': item.at.millisecondsSinceEpoch,
              'conceptIds': item.conceptIds,
              'skillIds': item.skillIds,
              'capabilityIds': item.capabilityIds,
            }).toList(),
      };

  StudentLearningState _fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) =>
        value is int ? DateTime.fromMillisecondsSinceEpoch(value) : null;

    final concepts = <String, ConceptState>{};
    for (final raw in (json['concepts'] as List<dynamic>? ?? const [])) {
      final item = raw as Map<String, dynamic>;
      final value = ConceptState(
        conceptId: item['conceptId'] as String,
        knowledgeLevel: (item['knowledgeLevel'] as num?)?.toDouble() ?? 0,
        lastUpdated: date(item['lastUpdated']),
      );
      concepts[value.conceptId] = value;
    }

    final skills = <String, SkillState>{};
    for (final raw in (json['skills'] as List<dynamic>? ?? const [])) {
      final item = raw as Map<String, dynamic>;
      final statusName = item['status'] as String? ?? 'missing';
      final status = StudentSkillStatus.values.firstWhere(
        (value) => value.name == statusName,
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
      final item = raw as Map<String, dynamic>;
      final value = CapabilityState(
        capabilityId: item['capabilityId'] as String,
        verified: item['verified'] as bool? ?? false,
        lastUpdated: date(item['lastUpdated']),
      );
      capabilities[value.capabilityId] = value;
    }

    final history = <LearningHistoryEntry>[];
    for (final raw in (json['history'] as List<dynamic>? ?? const [])) {
      final item = raw as Map<String, dynamic>;
      final timestamp = item['at'] as int?;
      if (timestamp == null) continue;
      history.add(LearningHistoryEntry(
        sourceId: item['sourceId'] as String,
        sourceType: item['sourceType'] as String,
        at: DateTime.fromMillisecondsSinceEpoch(timestamp),
        conceptIds: List<String>.from(item['conceptIds'] as List<dynamic>? ?? const []),
        skillIds: List<String>.from(item['skillIds'] as List<dynamic>? ?? const []),
        capabilityIds: List<String>.from(item['capabilityIds'] as List<dynamic>? ?? const []),
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
