import 'knowledge_graph.dart';
import 'abqari_models.dart';

class AbqariLearningGap {
  const AbqariLearningGap({required this.query, required this.missing, required this.recommendedKnowledge});
  final String query;
  final bool missing;
  final List<AbqariKnowledgeItem> recommendedKnowledge;
}

class AbqariLearningGapEngine {
  const AbqariLearningGapEngine({this.graph = const AbqariKnowledgeGraph()});
  final AbqariKnowledgeGraph graph;

  AbqariLearningGap analyze(String projectNeed) {
    final knowledge = graph.concepts(projectNeed);
    return AbqariLearningGap(
      query: projectNeed,
      missing: knowledge.isEmpty,
      recommendedKnowledge: knowledge,
    );
  }
}