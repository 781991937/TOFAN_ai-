import 'experience_memory.dart';

abstract interface class ExperienceMemoryRepository {
  Future<void> save(AbqariExperience experience);
  Future<List<AbqariExperience>> load({String? actorId, String? skillId});
  Future<void> clear({String? actorId});
}
