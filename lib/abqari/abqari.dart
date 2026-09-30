export 'abqari_models.dart';
export 'academic_knowledge_engine.dart';
export 'project_engine.dart';

class TofanAbqari {
  const TofanAbqari({this.projectEngine = const AbqariProjectEngine()});
  final AbqariProjectEngine projectEngine;
  AbqariProjectPlan analyzeProject(String idea) => projectEngine.plan(AbqariProjectRequest(idea: idea));
}