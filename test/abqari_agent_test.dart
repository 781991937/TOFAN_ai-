import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/abqari_agent.dart';
import 'package:tofan_ai/data/academic/academic_library_security.dart';

void main() {
  const agent = TofanAbqariAgent();

  test('routes academic requests through protected library retrieval', () {
    final task = agent.classify('اشرح مفهوم الذكاء الاصطناعي');
    expect(task.kind, AbqariTaskKind.academic);
    expect(task.risk, AbqariRiskLevel.low);
    final result = agent.handle('اشرح مفهوم الذكاء الاصطناعي', role: LibrarySecurityRole.knowledgeAgent);
    expect(result.blocked, isFalse);
    expect(result.knowledge, isNotEmpty);
  });

  test('routes projects to the existing project engine', () {
    final result = agent.handle('ابن مشروع نظام ذكاء اصطناعي');
    expect(result.task.kind, AbqariTaskKind.project);
    expect(result.actions, isNotEmpty);
  });

  test('requires approval for high-impact personal safety requests', () {
    final task = agent.classify('هناك شخص يهدد أخي، ماذا أفعل؟');
    expect(task.kind, AbqariTaskKind.personalSafety);
    expect(task.risk, AbqariRiskLevel.high);
    expect(task.requiresApproval, isTrue);
  });

  test('routes cyber attack intent to the bounded cyber engine', () {
    final result = agent.handle('يوجد هجوم على lab-node، نريد مهاجمته');
    expect(result.task.kind, AbqariTaskKind.cybersecurity);
    expect(result.approvalRequired, isTrue);
    expect(result.actions.any((step) => step.contains('محاكاة')), isTrue);
  });

  test('student cannot search the protected cybersecurity compartment', () {
    final result = agent.handle('اشرح الأمن السيبراني', role: LibrarySecurityRole.student);
    expect(result.knowledge, isEmpty);
  });
}
