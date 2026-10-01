class AbqariKnowledgeItem {
  const AbqariKnowledgeItem({required this.id, required this.title, required this.sourcePath,
    required this.content,
    this.definition = '',
    this.applications = const [],
    this.learningOutcomes = const [],
    this.terms = const [],
    this.conceptIds = const [],
    this.skillIds = const [],
    this.knowledgeAreaIds = const [],
    this.knowledgeUnitIds = const [],
    this.courseId = '',
    this.unitId = '',
    this.lessonId = '',
    this.projectTitles = const []});
  final String id, title, sourcePath, content;
  final String definition;
  final List<String> applications, learningOutcomes, terms, conceptIds, skillIds, knowledgeAreaIds, knowledgeUnitIds, projectTitles;
  final String courseId, unitId, lessonId;
}
class AbqariProjectRequest {
  const AbqariProjectRequest({required this.idea});
  final String idea;
}
class AbqariProjectPlan {
  const AbqariProjectPlan({required this.idea, required this.requirements, required this.disciplines, required this.knowledge, required this.skills, required this.knowledgeGaps, required this.phases, required this.softwareOutputs, required this.physicalComponents,
    this.sourceCourseIds = const [],
    this.sourceProjectTitles = const [],
    this.sourceLessonIds = const [],
    this.sourceKnowledgeUnitIds = const []});
  final String idea;
  final List<String> requirements, disciplines, skills, knowledgeGaps, phases, softwareOutputs, physicalComponents;
  /// Exact academic sources the plan was derived from; no parallel curriculum is created.
  final List<String> sourceCourseIds, sourceProjectTitles, sourceLessonIds, sourceKnowledgeUnitIds;
  final List<AbqariKnowledgeItem> knowledge;
}