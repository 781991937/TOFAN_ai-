import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/application/execution/safe_workspace.dart';
import 'package:tofan_ai/domain/execution/execution_models.dart';

void main() {
  test('workspace denies commands outside its explicit allowlist', () {
    const workspace = SafeWorkspace(
      policy: WorkspacePolicy(
        allowedCommands: ['python'],
        blockedCommands: ['python -c', 'python -m pip'],
      ),
    );

    expect(
      workspace.authorize(
        const WorkspaceRequest(command: 'python app.py', workspaceId: 'w1'),
      ),
      isTrue,
    );
    expect(
      workspace.authorize(
        const WorkspaceRequest(command: 'python -c print(1)', workspaceId: 'w1'),
      ),
      isFalse,
    );
    expect(
      workspace.authorize(
        const WorkspaceRequest(command: 'bash app.sh', workspaceId: 'w1'),
      ),
      isFalse,
    );
  });

  test('empty workspace policy is deny-by-default', () {
    const workspace = SafeWorkspace();
    expect(
      workspace.authorize(
        const WorkspaceRequest(command: 'python app.py', workspaceId: 'w1'),
      ),
      isFalse,
    );
  });
}
