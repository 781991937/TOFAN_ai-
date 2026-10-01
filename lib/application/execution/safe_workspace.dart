import '../../domain/execution/execution_models.dart';

/// Policy-only safe workspace boundary.
///
/// This class intentionally does not spawn processes or access the host OS.
/// A platform-specific sandbox adapter can implement execution behind this
/// contract later; authorization remains centralized here.
class SafeWorkspace {
  const SafeWorkspace({this.policy = const WorkspacePolicy(allowedCommands: [])});

  final WorkspacePolicy policy;

  bool authorize(WorkspaceRequest request) =>
      policy.allowsCommand(request.command);

  WorkspacePolicy get effectivePolicy => policy;
}
