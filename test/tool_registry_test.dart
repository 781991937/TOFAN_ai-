import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/tools/tool_registry.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';

void main() {
  test('registry keeps tool contracts unique and checks scoped authorization', () {
    const tool = ToolContract(
      id: 'library.search',
      operation: 'search',
      resource: 'academic-library',
      permissions: [ToolPermission.search],
    );
    final registry = const TofanToolRegistry().register(tool);

    expect(registry.find('library.search'), isNotNull);
    expect(
      registry.canInvoke(
        toolId: 'library.search',
        authorization: const ToolAuthorization(
          actorId: 'student-1',
          permissions: [ToolPermission.search],
          resourceScope: ['academic-library'],
        ),
      ),
      isTrue,
    );
    expect(
      registry.canInvoke(
        toolId: 'library.search',
        authorization: const ToolAuthorization(
          actorId: 'student-1',
          permissions: [ToolPermission.search],
          resourceScope: ['other-resource'],
        ),
      ),
      isFalse,
    );
  });

  test('unknown tools are denied by default', () {
    const registry = TofanToolRegistry();
    expect(
      registry.canInvoke(
        toolId: 'missing',
        authorization: const ToolAuthorization(
          actorId: 'student-1',
          permissions: [ToolPermission.search],
          resourceScope: ['academic-library'],
        ),
      ),
      isFalse,
    );
  });

  test('duplicate tool ids are rejected', () {
    const tool = ToolContract(
      id: 'library.search',
      operation: 'search',
      resource: 'academic-library',
      permissions: [ToolPermission.search],
    );
    final registry = const TofanToolRegistry().register(tool);
    expect(() => registry.register(tool), throwsArgumentError);
  });
}
