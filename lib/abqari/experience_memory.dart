enum ExperienceOutcome { success, partial, failure, blocked }

class AbqariExperience {
  const AbqariExperience({required this.id, required this.actorId, required this.task, required this.outcome, required this.observation, required this.learnedSkillIds, required this.createdAt});
  final String id;
  final String actorId;
  final String task;
  final ExperienceOutcome outcome;
  final String observation;
  final List<String> learnedSkillIds;
  final DateTime createdAt;
}

class AbqariExperienceMemory {
  const AbqariExperienceMemory([this.entries = const []]);
  final List<AbqariExperience> entries;
  AbqariExperienceMemory record(AbqariExperience experience) => AbqariExperienceMemory(List.unmodifiable([...entries, experience]));
  List<AbqariExperience> forSkill(String skillId) => List.unmodifiable(entries.where((entry) => entry.learnedSkillIds.contains(skillId)));
}
