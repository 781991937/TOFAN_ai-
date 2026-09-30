export 'abqari_models.dart';
export 'academic_knowledge_engine.dart';
export 'knowledge_graph.dart';
export 'learning_gap_engine.dart';
export 'project_engine.dart';
export 'cyber_command_engine.dart';
export 'abqari_agent.dart';
export 'security_lab.dart';
export 'experience_memory.dart';
export 'assessment_experience_bridge.dart';
export 'planning_engine.dart';

class TofanAbqari {
  const TofanAbqari({
    this.projectEngine = const AbqariProjectEngine(),
    this.agent = const TofanAbqariAgent(),
  });

  final AbqariProjectEngine projectEngine;
  final TofanAbqariAgent agent;

  AbqariProjectPlan analyzeProject(String idea) =>
      projectEngine.plan(AbqariProjectRequest(idea: idea));

  AbqariAgentResult handle(String request) => agent.handle(request);

  AbqariActionPlan plan(String request) => agent.plan(request);
}