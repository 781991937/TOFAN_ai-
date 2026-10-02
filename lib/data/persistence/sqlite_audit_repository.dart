import '../../database/app_database.dart';
import '../../domain/security/audit_models.dart';
import '../../domain/security/audit_repository.dart';

class SqliteAuditRepository implements AuditRepository {
  SqliteAuditRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<void> save(AuditEvent event) => _database.recordAuditEvent(event);

  @override
  Future<List<AuditEvent>> load({
    String? actorId,
    String? resourceId,
  }) =>
      _database.getAuditEvents(
        actorId: actorId,
        resourceId: resourceId,
      );
}
