import 'academic_knowledge_engine.dart';
import 'abqari_models.dart';

class AbqariKnowledgeEvidence {
  const AbqariKnowledgeEvidence({
    required this.item,
    required this.score,
    required this.knowledgeUnitIds,
    required this.skillIds,
    required this.conceptIds,
  });

  final AbqariKnowledgeItem item;
  final int score;
  final List<String> knowledgeUnitIds;
  final List<String> skillIds;
  final List<String> conceptIds;
}

/// Lightweight knowledge graph facade over canonical academic evidence.
/// The graph is intentionally derived from the library rather than storing a
/// second, drifting copy of the curriculum.
class AbqariKnowledgeGraph {
  const AbqariKnowledgeGraph({this.engine = const AcademicKnowledgeEngine()});
  final AcademicKnowledgeEngine engine;

  List<AbqariKnowledgeItem> concepts(String query) => engine.search(query);

  List<AbqariKnowledgeEvidence> evidenceFor(String query) {
    final items = engine.search(query);
    final tokens = _tokens(query);
    return items.map((item) {
      final score = _score(item, tokens);
      return AbqariKnowledgeEvidence(
        item: item,
        score: score,
        knowledgeUnitIds: item.knowledgeUnitIds,
        skillIds: item.skillIds,
        conceptIds: item.conceptIds,
      );
    }).toList(growable: false);
  }

  List<String> skillsFor(String query) {
    final items = engine.search(query);
    return <String>{for (final item in items) ...item.skillIds}.toList(growable: false);
  }

  List<String> conceptsFor(String query) {
    final items = engine.search(query);
    return <String>{for (final item in items) ...item.conceptIds}.toList(growable: false);
  }

  List<String> knowledgeUnitsFor(String query) {
    final items = engine.search(query);
    return <String>{for (final item in items) ...item.knowledgeUnitIds}.toList(growable: false);
  }

  bool containsKnowledge(String query) => engine.search(query).isNotEmpty;

  List<String> _tokens(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^\p{L}\p{N}_]+', unicode: true))
      .where((token) => token.length > 1)
      .toList(growable: false);

  int _score(AbqariKnowledgeItem item, List<String> tokens) {
    final haystack = <String>[
      item.title,
      item.definition,
      item.content,
      ...item.terms,
      ...item.knowledgeUnitIds,
    ].join(' ').toLowerCase();
    return tokens.where(haystack.contains).length;
  }
}
