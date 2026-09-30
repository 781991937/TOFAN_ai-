import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/abqari_agent.dart';

void main() {
  test('Abqari planning exposes retrieval through an authority boundary', () {
    const agent = TofanAbqariAgent();
    final plan = agent.plan('اشرح الوكيل في الذكاء الاصطناعي');
    expect(plan.stages.length, 8);
    expect(plan.knowledge, isNotEmpty);
    expect(plan.skillIds, isNotEmpty);
    expect(plan.requiresApproval, isFalse);
  });

  test('high-impact requests remain approval-gated in planning', () {
    const agent = TofanAbqariAgent();
    final plan = agent.plan('هناك تهديد وأحتاج خطة حماية');
    expect(plan.requiresApproval, isTrue);
  });
}
