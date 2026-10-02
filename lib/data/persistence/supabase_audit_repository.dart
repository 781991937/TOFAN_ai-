import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/security/audit_models.dart';
import '../../domain/security/audit_repository.dart';

class SupabaseAuditRepository implements AuditRepository {
  SupabaseAuditRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String _requireActor(String actorId) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('An active Supabase user is required.');
    }
    if (actorId.isEmpty || actorId != userId) {
      throw StateError('Audit actor does not match the authenticated user.');
    }
    return userId;
  }

  @override
  Future<void> save(AuditEvent event) async {
    final actorId = _requireActor(event.actorId);
    await _client.from('audit_events').insert({
      'id': event.id,
      'actor_id': actorId,
      'action': event.action,
      'resource_id': event.resourceId,
      'outcome': event.outcome.name,
      'timestamp': event.timestamp.toUtc().toIso8601String(),
      'reason': event.reason,
    });
  }

  @override
  Future<List<AuditEvent>> load({
    String? actorId,
    String? resourceId,
  }) async {
    final current = _client.auth.currentUser?.id;
    if (current == null || current.isEmpty) {
      throw StateError('An active Supabase user is required.');
    }
    if (actorId != null && actorId != current) {
      throw StateError('Audit actor does not match the authenticated user.');
    }

    var query = _client.from('audit_events').select().eq('actor_id', current);
    if (resourceId != null) {
      query = query.eq('resource_id', resourceId);
    }
    final rows = await query.order('timestamp', ascending: false);
    return rows.map((row) => AuditEvent(
      id: row['id'] as String,
      actorId: row['actor_id'] as String,
      action: row['action'] as String,
      resourceId: row['resource_id'] as String,
      outcome: AuditOutcome.values.firstWhere(
        (value) => value.name == row['outcome'],
        orElse: () => AuditOutcome.failure,
      ),
      timestamp: DateTime.parse(row['timestamp'] as String),
      reason: row['reason'] as String? ?? '',
    )).toList();
  }
}
