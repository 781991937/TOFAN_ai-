import 'abqari_models.dart';
import 'knowledge_graph.dart';

enum AbqariPlanStage {
  interpret,
  retrieve,
  assessRisk,
  checkAuthority,
  plan,
  act,
  evaluate,
  remember,
}

class AbqariActionPlan {
  const AbqariActionPlan({
    required this.request,
    required this.stages,
    required this.knowledge,
    required this.skillIds,
    required this.requiresApproval,
  });

  final String request;
  final List<AbqariPlanStage> stages;
  final List<AbqariKnowledgeEvidence> knowledge;
  final List<String> skillIds;
  final bool requiresApproval;
}

/// Deterministic planning skeleton for TOFAN AL-ABQARI.
/// It decides the sequence of reasoning boundaries; it does not grant tools or
/// permissions and never executes an external side effect by itself.
class AbqariPlanningEngine {
  const AbqariPlanningEngine({
    this.graph = const AbqariKnowledgeGraph(),
  });

  final AbqariKnowledgeGraph graph;

  AbqariActionPlan plan({
    required String request,
    required bool requiresApproval,
  }) {
    final evidence = graph.evidenceFor(request);
    final skills = <String>{
      for (final item in evidence) ...item.skillIds,
    };

    return AbqariActionPlan(
      request: request,
      stages: const [
        AbqariPlanStage.interpret,
        AbqariPlanStage.retrieve,
        AbqariPlanStage.assessRisk,
        AbqariPlanStage.checkAuthority,
        AbqariPlanStage.plan,
        AbqariPlanStage.act,
        AbqariPlanStage.evaluate,
        AbqariPlanStage.remember,
      ],
      knowledge: evidence,
      skillIds: skills.toList(growable: false),
      requiresApproval: requiresApproval,
    );
  }
}
