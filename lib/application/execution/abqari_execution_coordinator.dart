import '../../domain/execution/execution_models.dart';
import 'correction_loop.dart';
import 'safe_workspace.dart';
import '../tools/tool_registry.dart';

class AbqariExecutionCoordinator {
  const AbqariExecutionCoordinator({this.registry = const TofanToolRegistry(), this.workspace = const SafeWorkspace(), this.correctionLoop = const CorrectionLoop()});
  final TofanToolRegistry registry;
  final SafeWorkspace workspace;
  final CorrectionLoop correctionLoop;

  bool authorize({required String toolId, required ToolAuthorization authorization, required WorkspaceRequest workspaceRequest}) => registry.canInvoke(toolId: toolId, authorization: authorization) && workspace.authorize(workspaceRequest);

  CorrectionPlan planCorrection({required String affectedComponent, required String error}) => correctionLoop.plan(affectedComponent: affectedComponent, error: error);

  ExecutionTrace recordResult({required String task, required List<String> plan, required ExecutionOutcome outcome, required CorrectionPlan correction, required List<TestEvidence> tests, List<String> evidence = const []}) => correctionLoop.recordRetest(task: task, plan: plan, outcome: outcome, correction: correction, tests: tests, evidence: evidence);
}
