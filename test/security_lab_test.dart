import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/abqari/security_lab.dart';

void main() {
  const engine = SmartSecurityLabEngine();

  test('lab requires explicit authorization', () {
    final plan = engine.plan(
      scenarioId: 'web-authz-01',
      assetId: 'lab/web-01',
    );
    expect(plan.status, SecurityLabStatus.blocked);
  });

  test('lab rejects an asset outside the authorized scope', () {
    final plan = engine.plan(
      scenarioId: 'web-authz-01',
      assetId: 'prod/web-01',
      authorization: SecurityLabAuthorization(
        actorId: 'student-1',
        scope: 'lab/*',
        expiresAt: DateTime.utc(2026, 12, 1),
      ),
      now: DateTime.utc(2026, 10, 1),
    );
    expect(plan.status, SecurityLabStatus.blocked);
  });

  test('authorized lab exposes the controlled lifecycle', () {
    final plan = engine.plan(
      scenarioId: 'web-authz-01',
      assetId: 'lab/web-01',
      authorization: SecurityLabAuthorization(
        actorId: 'student-1',
        scope: 'lab/*',
        expiresAt: DateTime.utc(2026, 12, 1),
      ),
      now: DateTime.utc(2026, 10, 1),
    );
    expect(plan.isReady, isTrue);
    expect(plan.phases, SecurityLabPhase.values);
  });

  test('verification cannot complete before remediation', () {
    final evaluation = engine.evaluate(
      SecurityLabSubmission(
        labId: 'web-authz-01',
        assetId: 'lab/web-01',
        completedPhases: SecurityLabPhase.values,
        evidence: const ['evidence'],
        findings: const [
          SecurityLabFinding(
            id: 'f-1',
            title: 'صلاحية غير صحيحة',
            description: 'ملاحظة تدريبية.',
            severity: 3,
            knowledgeUnitIds: ['sec-02'],
            skillIds: ['cyber.authorization.testing'],
          ),
        ],
        remediation: const ['تصحيح سياسة الدور'],
        remediationComplete: false,
        verificationPassed: false,
      ),
    );
    expect(evaluation.status, SecurityLabStatus.awaitingRemediation);
    expect(evaluation.score, lessThan(100));
  });

  test('completed lab produces skill evidence', () {
    final evaluation = engine.evaluate(
      SecurityLabSubmission(
        labId: 'web-authz-01',
        assetId: 'lab/web-01',
        completedPhases: SecurityLabPhase.values,
        evidence: const ['scope', 'evidence'],
        findings: const [
          SecurityLabFinding(
            id: 'f-1',
            title: 'صلاحية غير صحيحة',
            description: 'ملاحظة تدريبية.',
            severity: 3,
            knowledgeUnitIds: ['sec-02'],
            skillIds: ['cyber.authorization.testing'],
          ),
        ],
        remediation: const ['تصحيح سياسة الدور'],
        remediationComplete: true,
        verificationPassed: true,
      ),
    );
    expect(evaluation.status, SecurityLabStatus.completed);
    expect(evaluation.score, 100);
    expect(evaluation.skillEvidence, contains('cyber.authorization.testing'));
  });
}
