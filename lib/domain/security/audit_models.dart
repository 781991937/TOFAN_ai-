enum AuditOutcome { allowed, denied, blocked, success, failure }

class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.actorId,
    required this.action,
    required this.resourceId,
    required this.outcome,
    required this.timestamp,
    this.reason = '',
  });

  final String id;
  final String actorId;
  final String action;
  final String resourceId;
  final AuditOutcome outcome;
  final DateTime timestamp;
  final String reason;
}

class AuditLog {
  const AuditLog([this.events = const []]);
  final List<AuditEvent> events;

  AuditLog record(AuditEvent event) =>
      AuditLog(List.unmodifiable([...events, event]));

  List<AuditEvent> forActor(String actorId) =>
      List.unmodifiable(events.where((event) => event.actorId == actorId));

  List<AuditEvent> forResource(String resourceId) =>
      List.unmodifiable(events.where((event) => event.resourceId == resourceId));
}
