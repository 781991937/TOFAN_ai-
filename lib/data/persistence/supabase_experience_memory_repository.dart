import 'package:supabase_flutter/supabase_flutter.dart';

import '../../abqari/experience_memory.dart';
import '../../abqari/experience_memory_repository.dart';

class SupabaseExperienceMemoryRepository implements ExperienceMemoryRepository {
  SupabaseExperienceMemoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String _requireActor(String actorId) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('An active Supabase user is required.');
    }
    if (actorId.isEmpty || actorId != userId) {
      throw StateError('Experience actor does not match the authenticated user.');
    }
    return userId;
  }

  @override
  Future<void> save(AbqariExperience experience) async {
    final actorId = _requireActor(experience.actorId);
    await _client.from('experience_memory').insert({
      'id': experience.id,
      'actor_id': actorId,
      'task': experience.task,
      'outcome': experience.outcome.name,
      'observation': experience.observation,
      'learned_skill_ids': experience.learnedSkillIds,
      'created_at': experience.createdAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<AbqariExperience>> load({String? actorId, String? skillId}) async {
    final current = _client.auth.currentUser?.id;
    if (current == null || current.isEmpty) {
      throw StateError('An active Supabase user is required.');
    }
    if (actorId != null && actorId != current) {
      throw StateError('Experience actor does not match the authenticated user.');
    }

    var query = _client.from('experience_memory').select().eq('actor_id', current);
    if (skillId != null) {
      query = query.contains('learned_skill_ids', [skillId]);
    }
    final rows = await query.order('created_at', ascending: false);
    return rows.map((row) => AbqariExperience(
      id: row['id'] as String,
      actorId: row['actor_id'] as String,
      task: row['task'] as String,
      outcome: ExperienceOutcome.values.firstWhere(
        (value) => value.name == row['outcome'],
        orElse: () => ExperienceOutcome.failure,
      ),
      observation: row['observation'] as String,
      learnedSkillIds: List<String>.from(row['learned_skill_ids'] as List? ?? const []),
      createdAt: DateTime.parse(row['created_at'] as String),
    )).toList();
  }

  @override
  Future<void> clear({String? actorId}) async {
    final current = _client.auth.currentUser?.id;
    if (current == null || current.isEmpty) {
      throw StateError('An active Supabase user is required.');
    }
    if (actorId != null && actorId != current) {
      throw StateError('Experience actor does not match the authenticated user.');
    }
    await _client.from('experience_memory').delete().eq('actor_id', current);
  }
}
