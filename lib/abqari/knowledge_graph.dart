import 'academic_knowledge_engine.dart';
import 'abqari_models.dart';

class AbqariKnowledgeGraph {
  const AbqariKnowledgeGraph({this.engine = const AcademicKnowledgeEngine()});
  final AcademicKnowledgeEngine engine;

  List<AbqariKnowledgeItem> concepts(String query) => engine.search(query);

  List<String> skillsFor(String query) {
    final items = engine.search(query);
    return <String>{for (final item in items) ...item.skillIds}.toList(growable: false);
  }

  List<String> conceptsFor(String query) {
    final items = engine.search(query);
    return <String>{for (final item in items) ...item.conceptIds}.toList(growable: false);
  }

  bool containsKnowledge(String query) => engine.search(query).isNotEmpty;
}