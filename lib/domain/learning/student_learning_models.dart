enum StudentSkillStatus { missing, developing, acquired, demonstrated }

class ConceptState {
  const ConceptState({required this.conceptId, this.knowledgeLevel = 0, this.lastUpdated});
  final String conceptId;
  final double knowledgeLevel;
  final DateTime? lastUpdated;
}

class SkillState {
  const SkillState({required this.skillId, this.level = 0, this.status = StudentSkillStatus.missing, this.lastUpdated});
  final String skillId;
  final double level;
  final StudentSkillStatus status;
  final DateTime? lastUpdated;
}

class CapabilityState {
  const CapabilityState({required this.capabilityId, this.verified = false, this.lastUpdated});
  final String capabilityId;
  final bool verified;
  final DateTime? lastUpdated;
}

class LearningHistoryEntry {
  const LearningHistoryEntry({required this.sourceId, required this.sourceType, required this.at, this.conceptIds = const [], this.skillIds = const [], this.capabilityIds = const []});
  final String sourceId;
  final String sourceType;
  final DateTime at;
  final List<String> conceptIds;
  final List<String> skillIds;
  final List<String> capabilityIds;
}

class StudentLearningState {
  const StudentLearningState({
    this.concepts = const {},
    this.skills = const {},
    this.capabilities = const {},
    this.history = const [],
  });
  final Map<String, ConceptState> concepts;
  final Map<String, SkillState> skills;
  final Map<String, CapabilityState> capabilities;
  final List<LearningHistoryEntry> history;
}
