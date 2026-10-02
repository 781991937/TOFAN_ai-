import 'audit_models.dart';

abstract interface class AuditRepository {
  Future<void> save(AuditEvent event);
  Future<List<AuditEvent>> load({String? actorId, String? resourceId});
}
