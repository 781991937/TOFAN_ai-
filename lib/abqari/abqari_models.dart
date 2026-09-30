class AbqariKnowledgeItem {
  const AbqariKnowledgeItem({required this.id, required this.title, required this.sourcePath,
    required this.content,
    this.definition = '',
    this.applications = const [],
    this.learningOutcomes = const [],
    this.terms = const [],
    this.conceptIds = const [],
    this.skillIds = const [],
    this.knowledgeAreaIds = const []});
  final String id, title, sourcePath, content;
  final String definition;
  final List<String> applications, learningOutcomes, terms, conceptIds, skillIds, knowledgeAreaIds;
}
class AbqariProjectRequest {
  const AbqariProjectRequest({required this.idea});
  final String idea;
}
class AbqariProjectPlan {
  const AbqariProjectPlan({required this.idea, required this.requirements, required this.disciplines, required this.knowledge, required this.skills, required this.knowledgeGaps, required this.phases, required this.softwareOutputs, required this.physicalComponents});
  final String idea;
  final List<String> requirements, disciplines, skills, knowledgeGaps, phases, softwareOutputs, physicalComponents;
  final List<AbqariKnowledgeItem> knowledge;
}