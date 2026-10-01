import '../../abqari/experience_memory.dart';
import '../../abqari/experience_memory_repository.dart';
import '../../database/app_database.dart';

class SqliteExperienceMemoryRepository implements ExperienceMemoryRepository {
  SqliteExperienceMemoryRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<void> save(AbqariExperience experience) =>
      _database.saveExperience(experience);

  @override
  Future<List<AbqariExperience>> load({String? actorId, String? skillId}) =>
      _database.getExperiences(actorId: actorId, skillId: skillId);

  @override
  Future<void> clear({String? actorId}) =>
      _database.clearExperiences(actorId: actorId);
}
