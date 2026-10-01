import '../../domain/execution/execution_models.dart';
import 'execution_engine.dart';

/// Deterministic correction/re-test coordinator.
///
/// It records failure classification and produces a bounded next attempt.
/// It never mutates source code or executes tests itself.
class CorrectionLoop {
  const CorrectionLoop({this.executionEngine = const ExecutionEngine()});

  final ExecutionEngine executionEngine;

  CorrectionPlan plan({
    required String affectedComponent,
    required String error,
  }) =>
      executionEngine.classifyFailure(
        affectedComponent: affectedComponent,
        error: error,
      );

  ExecutionTrace recordRetest({
    required String task,
    required List<String> plan,
    required ExecutionOutcome outcome,
    required CorrectionPlan correction,
    required List<TestEvidence> tests,
    List<String> evidence = const [],
  }) {
    return ExecutionTrace(
      task: task,
      plan: List.unmodifiable(plan),
      outcome: outcome,
      errors: outcome == ExecutionOutcome.success ? const [] : [correction.rootCause],
      corrections: [correction],
      tests: List.unmodifiable(tests),
      evidence: List.unmodifiable(evidence),
    );
  }
}
