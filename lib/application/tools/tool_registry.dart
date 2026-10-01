import '../../domain/execution/execution_models.dart';
import '../execution/execution_engine.dart';

/// Canonical registry for TOFAN tool contracts.
///
/// Tools are descriptions plus policy boundaries; the registry never grants
/// permissions by itself and never executes a tool implementation.
class TofanToolRegistry {
  const TofanToolRegistry({
    this.tools = const <ToolContract>[],
  });

  final List<ToolContract> tools;

  ToolContract? find(String id) {
    for (final tool in tools) {
      if (tool.id == id) return tool;
    }
    return null;
  }

  bool canInvoke({
    required String toolId,
    required ToolAuthorization authorization,
  }) {
    final tool = find(toolId);
    if (tool == null) return false;
    return const ExecutionEngine().authorizeTool(
      tool: tool,
      authorization: authorization,
    );
  }

  TofanToolRegistry register(ToolContract tool) {
    if (find(tool.id) != null) {
      throw ArgumentError('Tool id already registered: ${tool.id}');
    }
    return TofanToolRegistry(tools: List.unmodifiable([...tools, tool]));
  }
}
