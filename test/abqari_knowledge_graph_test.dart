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

  test('prerequisite graph exposes canonical edges without duplicating curriculum', () {
    const graph = AbqariKnowledgeGraph();
    final edges = graph.prerequisiteEdges();
    expect(edges, isNotEmpty);
    expect(graph.prerequisitesFor('python'), isEmpty);
    expect(graph.prerequisiteCycleCourseIds(), isEmpty);
    expect(graph.danglingPrerequisiteEdges(), isEmpty);
  });

  test('rich graph exposes canonical lesson, skill, assessment and project relations', () {
    const graph = AbqariKnowledgeGraph();
    final edges = graph.academicEdges();
    expect(edges, isNotEmpty);
    expect(edges.any((e) => e.relation == AcademicGraphRelation.courseToKnowledgeUnit), isTrue);
    expect(edges.any((e) => e.relation == AcademicGraphRelation.lessonToConcept), isTrue);
    expect(edges.any((e) => e.relation == AcademicGraphRelation.lessonToSkill), isTrue);
    expect(edges.any((e) => e.relation == AcademicGraphRelation.assessmentToSkill), isTrue);
    expect(edges.any((e) => e.relation == AcademicGraphRelation.projectToSkill), isTrue);
    final skillEdge = edges.firstWhere((e) => e.relation == AcademicGraphRelation.lessonToSkill);
    expect(graph.lessonsForSkill(skillEdge.toId), contains(skillEdge.fromId));
    expect(graph.coursesForSkill(skillEdge.toId), isNotEmpty);
    final projectEdge = edges.firstWhere((e) => e.relation == AcademicGraphRelation.projectToSkill);
    expect(graph.projectsForSkill(projectEdge.toId), contains(projectEdge.fromId));
  });

  test('prerequisite closure and reverse traversal are consistent', () {
    const graph = AbqariKnowledgeGraph();
    final edges = graph.prerequisiteEdges();
    final edge = edges.first;
    expect(graph.prerequisiteChain(edge.courseId), contains(edge.prerequisiteCourseId));
    expect(graph.dependentsFor(edge.prerequisiteCourseId), contains(edge.courseId));
  });
}
