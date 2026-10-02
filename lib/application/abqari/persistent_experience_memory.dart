import '../../abqari/experience_memory.dart';
import '../../abqari/experience_memory_repository.dart';

class PersistentExperienceMemory {
  PersistentExperienceMemory({required this.repository});

  final ExperienceMemoryRepository repository;

  Future<void> record(AbqariExperience experience) =>
      repository.save(experience);

  Future<List<AbqariExperience>> forSkill(String skillId) =>
      repository.load(skillId: skillId);

  Future<List<AbqariExperience>> forActor(String actorId) =>
      repository.load(actorId: actorId);

  Future<void> clearActor(String actorId) =>
      repository.clear(actorId: actorId);
}
