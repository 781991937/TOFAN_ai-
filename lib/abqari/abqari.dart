import 'planning_engine.dart';
import 'project_engine.dart';
import 'abqari_agent.dart';
import 'abqari_models.dart';

export 'abqari_models.dart';
export 'academic_knowledge_engine.dart';
export 'knowledge_graph.dart';
export 'learning_gap_engine.dart';
export 'project_engine.dart';
export 'cyber_command_engine.dart';
export 'abqari_agent.dart';
export 'security_lab.dart';
export 'experience_memory.dart';
export 'experience_memory_repository.dart';
export 'assessment_experience_bridge.dart';
export 'planning_engine.dart';
export '../application/tools/tool_registry.dart';
export '../application/execution/abqari_execution_coordinator.dart';
export '../domain/files/academic_document_models.dart';
export '../application/files/academic_document_mapper.dart';
export '../application/files/academic_document_extractor.dart';
export '../application/files/academic_document_pipeline.dart';
export '../domain/security/agent_authorization_models.dart';
export '../domain/security/authentication_models.dart';
export '../application/ai/agent_gateway.dart';
export '../domain/security/oc_auth_models.dart';
export '../domain/security/audit_models.dart';
export '../domain/learning/student_learning_repository.dart';
export '../data/persistence/sqlite_student_learning_repository.dart';
export '../data/persistence/sqlite_experience_memory_repository.dart';

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
