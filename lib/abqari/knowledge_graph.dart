import '../domain/academic/academic_models.dart';
import '../data/academic/academic_catalog.dart';
import 'academic_knowledge_engine.dart';
import 'abqari_models.dart';

enum AcademicGraphNodeType { course, knowledgeArea, knowledgeUnit, lesson, concept, skill, project, assessmentQuestion, learningOutcome }

enum AcademicGraphRelation {
  courseToKnowledgeArea, courseToKnowledgeUnit, courseToPrerequisite,
  lessonToConcept, lessonToSkill, assessmentToOutcome, assessmentToConcept,
  assessmentToSkill, projectToSkill, projectToConcept,
}

class AcademicKnowledgeGraphEdge {
  const AcademicKnowledgeGraphEdge({
    required this.fromType, required this.fromId, required this.relation,
    required this.toType, required this.toId,
  });
  final AcademicGraphNodeType fromType;
  final String fromId;
  final AcademicGraphRelation relation;
  final AcademicGraphNodeType toType;
  final String toId;
}

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

/// Course-level prerequisite edge derived directly from the canonical catalog.
/// The graph stores no second curriculum; it only exposes relationships that
/// already exist on AcademicCourse.prerequisiteCourseIds.
class AcademicPrerequisiteEdge {
  const AcademicPrerequisiteEdge({
    required this.courseId,
    required this.prerequisiteCourseId,
  });

  final String courseId;
  final String prerequisiteCourseId;
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

  /// Rich relationships derived only from canonical academic models.
  List<AcademicKnowledgeGraphEdge> academicEdges() {
    final edges = <AcademicKnowledgeGraphEdge>[];
    for (final course in _allCourses()) {
      for (final areaId in course.knowledgeAreaIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.course, fromId: course.id, relation: AcademicGraphRelation.courseToKnowledgeArea, toType: AcademicGraphNodeType.knowledgeArea, toId: areaId));
      for (final unitId in course.knowledgeUnitIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.course, fromId: course.id, relation: AcademicGraphRelation.courseToKnowledgeUnit, toType: AcademicGraphNodeType.knowledgeUnit, toId: unitId));
      for (final prerequisiteId in course.prerequisiteCourseIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.course, fromId: course.id, relation: AcademicGraphRelation.courseToPrerequisite, toType: AcademicGraphNodeType.course, toId: prerequisiteId));
      for (final unit in course.normalizedUnits) for (final lesson in unit.lessons) {
        for (final skillId in lesson.skillIds) edges.add(AcademicKnowledgeGraphEdge(
          fromType: AcademicGraphNodeType.skill,
          fromId: skillId,
          relation: AcademicGraphRelation.skillToCourse,
          toType: AcademicGraphNodeType.course,
          toId: course.id,
        ));
        for (final conceptId in lesson.conceptIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.lesson, fromId: lesson.id, relation: AcademicGraphRelation.lessonToConcept, toType: AcademicGraphNodeType.concept, toId: conceptId));
        for (final skillId in lesson.skillIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.lesson, fromId: lesson.id, relation: AcademicGraphRelation.lessonToSkill, toType: AcademicGraphNodeType.skill, toId: skillId));
        for (final assessment in lesson.assessments) for (final question in assessment.questions) {
          for (final index in question.learningOutcomeIndexes) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.assessmentQuestion, fromId: question.id, relation: AcademicGraphRelation.assessmentToOutcome, toType: AcademicGraphNodeType.learningOutcome, toId: lesson.id+':outcome:'+index.toString()));
          for (final conceptId in question.conceptIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.assessmentQuestion, fromId: question.id, relation: AcademicGraphRelation.assessmentToConcept, toType: AcademicGraphNodeType.concept, toId: conceptId));
          for (final skillId in question.skillIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.assessmentQuestion, fromId: question.id, relation: AcademicGraphRelation.assessmentToSkill, toType: AcademicGraphNodeType.skill, toId: skillId));
        }
        for (final project in [...lesson.projects, ...course.projects]) {
          for (final skillId in project.skillIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.project, fromId: project.id, relation: AcademicGraphRelation.projectToSkill, toType: AcademicGraphNodeType.skill, toId: skillId));
          for (final conceptId in project.conceptIds) edges.add(AcademicKnowledgeGraphEdge(fromType: AcademicGraphNodeType.project, fromId: project.id, relation: AcademicGraphRelation.projectToConcept, toType: AcademicGraphNodeType.concept, toId: conceptId));
        }
      }
    }
    return List.unmodifiable(edges);
  }
  /// Returns every explicit course prerequisite edge in the canonical catalog.
  List<AcademicPrerequisiteEdge> prerequisiteEdges() {
    final courses = _allCourses();
    return [
      for (final course in courses)
        for (final prerequisiteId in course.prerequisiteCourseIds)
          AcademicPrerequisiteEdge(
            courseId: course.id,
            prerequisiteCourseId: prerequisiteId,
          ),
    ];
  }

  /// Direct prerequisites declared by the canonical course definition.
  List<String> prerequisitesFor(String courseId) {
    final course = _courseById(courseId);
    return course?.prerequisiteCourseIds.toList(growable: false) ?? const [];
  }

  /// Transitive prerequisite closure, ordered from nearest to farthest.
  /// A visited set prevents malformed catalog cycles from causing recursion
  /// loops; cycle detection is exposed separately for quality-gate checks.
  List<String> prerequisiteChain(String courseId) {
    final result = <String>[];
    final visited = <String>{courseId};
    final queue = <String>[...prerequisitesFor(courseId)];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (!visited.add(current)) continue;
      result.add(current);
      queue.addAll(prerequisitesFor(current));
    }
    return result;
  }

  /// Courses that explicitly declare [courseId] as a prerequisite.
  List<String> dependentsFor(String courseId) => {
        for (final edge in prerequisiteEdges())
          if (edge.prerequisiteCourseId == courseId) edge.courseId,
      }.toList(growable: false);

  /// Finds course IDs participating in explicit prerequisite cycles.
  List<String> prerequisiteCycleCourseIds() {
    final cycles = <String>{};
    final visiting = <String>{};
    final visited = <String>{};
    final courses = _allCourses();

    void visit(String courseId) {
      if (visiting.contains(courseId)) {
        cycles.add(courseId);
        return;
      }
      if (!visited.add(courseId)) return;
      visiting.add(courseId);
      for (final prerequisiteId in prerequisitesFor(courseId)) {
        if (visiting.contains(prerequisiteId)) {
          cycles.add(courseId);
          cycles.add(prerequisiteId);
          continue;
        }
        visit(prerequisiteId);
      }
      visiting.remove(courseId);
    }

    for (final course in courses) visit(course.id);
    return cycles.toList(growable: false);
  }

  /// Returns prerequisite references that do not resolve to a canonical course.
  List<AcademicPrerequisiteEdge> danglingPrerequisiteEdges() {
    final courseIds = _allCourses().map((course) => course.id).toSet();
    return prerequisiteEdges()
        .where((edge) => !courseIds.contains(edge.prerequisiteCourseId))
        .toList(growable: false);
  }

  List<String> lessonsForConcept(String id) => _relatedIds(AcademicGraphNodeType.lesson, AcademicGraphNodeType.concept, AcademicGraphRelation.lessonToConcept, id);
  List<String> lessonsForSkill(String id) => _relatedIds(AcademicGraphNodeType.lesson, AcademicGraphNodeType.skill, AcademicGraphRelation.lessonToSkill, id);
  List<String> coursesForKnowledgeUnit(String id) => _relatedIds(AcademicGraphNodeType.course, AcademicGraphNodeType.knowledgeUnit, AcademicGraphRelation.courseToKnowledgeUnit, id);
  List<String> coursesForKnowledgeArea(String id) => _relatedIds(AcademicGraphNodeType.course, AcademicGraphNodeType.knowledgeArea, AcademicGraphRelation.courseToKnowledgeArea, id);
  List<String> coursesForSkill(String id) => _relatedIds(AcademicGraphNodeType.skill, AcademicGraphNodeType.course, AcademicGraphRelation.skillToCourse, id);
  List<String> projectsForSkill(String id) => _relatedIds(AcademicGraphNodeType.project, AcademicGraphNodeType.skill, AcademicGraphRelation.projectToSkill, id);
  List<String> projectsForConcept(String id) => _relatedIds(AcademicGraphNodeType.project, AcademicGraphNodeType.concept, AcademicGraphRelation.projectToConcept, id);
  List<String> assessmentQuestionsForSkill(String id) => _relatedIds(AcademicGraphNodeType.assessmentQuestion, AcademicGraphNodeType.skill, AcademicGraphRelation.assessmentToSkill, id);
  List<String> assessmentQuestionsForConcept(String id) => _relatedIds(AcademicGraphNodeType.assessmentQuestion, AcademicGraphNodeType.concept, AcademicGraphRelation.assessmentToConcept, id);

  List<String> _relatedIds(AcademicGraphNodeType from, AcademicGraphNodeType to, AcademicGraphRelation relation, String target) =>
      academicEdges().where((e) => e.fromType == from && e.toType == to && e.relation == relation && e.toId == target).map((e) => e.fromId).toSet().toList(growable: false);

  bool containsKnowledge(String query) => engine.search(query).isNotEmpty;

  List<AcademicCourse> _allCourses() => [
        ...AcademicCatalog.foundationCourses,
        ...AcademicCatalog.universities.expand((university) => university.colleges)
            .expand((college) => college.specializations)
            .expand((specialization) => specialization.years)
            .expand((year) => year.semesters)
            .expand((semester) => semester.courses),
      ];

  AcademicCourse? _courseById(String courseId) {
    for (final course in _allCourses()) {
      if (course.id == courseId) return course;
    }
    return null;
  }

  List<String> _tokens(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^\\p{L}\\p{N}_]+', unicode: true))
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
