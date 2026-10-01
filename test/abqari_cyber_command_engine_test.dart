import 'package:tofan_ai/data/academic/academic_library_security.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/cyber_command_engine.dart';

void main() {
  const engine = AbqariCyberCommandEngine();

  test('converts an attack order into an isolated simulation', () {
    final command = engine.parse('يوجد عدو يهاجم على lab-node، لازم نهاجمه');
    expect(command.action, AbqariCyberAction.simulateAttack);
    expect(command.mode, AbqariCyberMode.simulate);
    expect(command.requiresApproval, isTrue);

    final result = engine.execute(command);
    expect(result.steps.any((step) => step.contains('مختبر محاكاة')), isTrue);
    expect(result.steps.any((step) => step.contains('محاكاة')), isTrue);
  });

  test('defensive command produces a bounded local response', () {
    final command = engine.parse('دافع عن server-1');
    expect(command.action, AbqariCyberAction.isolateAsset);
    expect(command.mode, AbqariCyberMode.defend);

    final result = engine.execute(command);
    expect(result.steps.any((step) => step.contains('عزل')), isTrue);
  });

  test('never grants unrestricted library administration to agents', () {
    expect(
      engine.isLibraryGuarded(LibrarySecurityRole.knowledgeAgent),
      isTrue,
    );
    expect(
      engine.isLibraryGuarded(LibrarySecurityRole.student),
      isFalse,
    );
  });
}
