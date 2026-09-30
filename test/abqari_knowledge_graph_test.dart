import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/knowledge_graph.dart';

void main() {
  test('knowledge graph returns canonical unit and skill evidence', () {
    const graph = AbqariKnowledgeGraph();
    final evidence = graph.evidenceFor('الذكاء الاصطناعي الوكيل');
    expect(evidence, isNotEmpty);
    expect(evidence.any((item) => item.knowledgeUnitIds.isNotEmpty), isTrue);
    expect(graph.knowledgeUnitsFor('الذكاء الاصطناعي'), isNotEmpty);
    expect(graph.skillsFor('الذكاء الاصطناعي'), isNotEmpty);
  });
}
