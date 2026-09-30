enum SecurityLabScenarioType {
  authentication,
  authorization,
  session,
  inputValidation,
  networkSegmentation,
  incidentResponse,
  sampleAnalysis,
  cloudConfiguration,
  teamSimulation,
}

enum SecurityLabPhase {
  scope,
  assetInventory,
  observation,
  hypothesis,
  test,
  evidence,
  finding,
  remediation,
  verification,
  report,
}

enum SecurityLabStatus { ready, blocked, inProgress, awaitingRemediation, completed }

class SecurityLabScenario {
  const SecurityLabScenario({
    required this.id,
    required this.title,
    required this.type,
    required this.courseId,
    required this.knowledgeUnitIds,
    required this.skillIds,
    required this.description,
  });

  final String id;
  final String title;
  final SecurityLabScenarioType type;
  final String courseId;
  final List<String> knowledgeUnitIds;
  final List<String> skillIds;
  final String description;
}

class SecurityLabAuthorization {
  const SecurityLabAuthorization({
    required this.actorId,
    required this.scope,
    required this.expiresAt,
  });

  final String actorId;
  final String scope;
  final DateTime expiresAt;

  bool validFor(String assetId, DateTime now) =>
      actorId.trim().isNotEmpty &&
      scope.trim().isNotEmpty &&
      expiresAt.isAfter(now) &&
      (scope == '*' ||
          scope == assetId ||
          (scope.endsWith('/*') &&
              assetId.startsWith(scope.substring(0, scope.length - 1))));
}

class SecurityLabPlan {
  const SecurityLabPlan({
    required this.scenario,
    required this.assetId,
    required this.phases,
    required this.status,
    required this.reason,
  });

  final SecurityLabScenario scenario;
  final String assetId;
  final List<SecurityLabPhase> phases;
  final SecurityLabStatus status;
  final String reason;

  bool get isReady => status == SecurityLabStatus.ready;
}

class SecurityLabFinding {
  const SecurityLabFinding({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.knowledgeUnitIds,
    required this.skillIds,
  });

  final String id;
  final String title;
  final String description;
  final int severity;
  final List<String> knowledgeUnitIds;
  final List<String> skillIds;
}

class SecurityLabSubmission {
  const SecurityLabSubmission({
    required this.labId,
    required this.assetId,
    required this.completedPhases,
    required this.evidence,
    required this.findings,
    required this.remediation,
    this.remediationComplete = false,
    this.verificationPassed = false,
  });

  final String labId;
  final String assetId;
  final List<SecurityLabPhase> completedPhases;
  final List<String> evidence;
  final List<SecurityLabFinding> findings;
  final List<String> remediation;
  final bool remediationComplete;
  final bool verificationPassed;
}

class SecurityLabEvaluation {
  const SecurityLabEvaluation({
    required this.status,
    required this.score,
    required this.skillEvidence,
    required this.feedback,
    required this.nextPhase,
  });

  final SecurityLabStatus status;
  final double score;
  final List<String> skillEvidence;
  final List<String> feedback;
  final SecurityLabPhase nextPhase;
}

class SmartSecurityLabCatalog {
  const SmartSecurityLabCatalog._();

  static const scenarios = <SecurityLabScenario>[
    SecurityLabScenario(
      id: 'web-auth-01',
      title: 'مصادقة تطبيق ويب تدريبي',
      type: SecurityLabScenarioType.authentication,
      courseId: 'cyber-web-security',
      knowledgeUnitIds: ['sec-01'],
      skillIds: ['cyber.authentication.testing'],
      description: 'تحليل تدفق المصادقة في تطبيق تدريبي معتمد.',
    ),
    SecurityLabScenario(
      id: 'web-authz-01',
      title: 'التحكم في الصلاحيات',
      type: SecurityLabScenarioType.authorization,
      courseId: 'ethical-hacking-1',
      knowledgeUnitIds: ['sec-02'],
      skillIds: ['cyber.authorization.testing'],
      description: 'التحقق من تطبيق الأدوار والصلاحيات داخل المختبر.',
    ),
    SecurityLabScenario(
      id: 'session-01',
      title: 'أمن الجلسات',
      type: SecurityLabScenarioType.session,
      courseId: 'cyber-web-security',
      knowledgeUnitIds: ['sec-03'],
      skillIds: ['cyber.session.analysis'],
      description: 'تحليل دورة حياة الجلسة وخصائص الرموز في بيئة تدريبية.',
    ),
    SecurityLabScenario(
      id: 'input-01',
      title: 'التحقق من المدخلات',
      type: SecurityLabScenarioType.inputValidation,
      courseId: 'ethical-hacking-1',
      knowledgeUnitIds: ['sec-04'],
      skillIds: ['cyber.input.validation'],
      description: 'اختبار قواعد التحقق باستخدام بيانات تدريبية مصطنعة.',
    ),
    SecurityLabScenario(
      id: 'network-01',
      title: 'تقسيم الشبكة',
      type: SecurityLabScenarioType.networkSegmentation,
      courseId: 'network-security-1',
      knowledgeUnitIds: ['sec-05'],
      skillIds: ['cyber.network.segmentation'],
      description: 'تحليل مسارات اتصال افتراضية وفعالية العزل.',
    ),
    SecurityLabScenario(
      id: 'incident-01',
      title: 'الاستجابة لحادث',
      type: SecurityLabScenarioType.incidentResponse,
      courseId: 'incident-response',
      knowledgeUnitIds: ['sec-06'],
      skillIds: ['cyber.incident.response'],
      description: 'تحليل حادث اصطناعي وجمع الأدلة والاحتواء والتعافي.',
    ),
    SecurityLabScenario(
      id: 'sample-01',
      title: 'تحليل عينة تدريبية',
      type: SecurityLabScenarioType.sampleAnalysis,
      courseId: 'malware-analysis',
      knowledgeUnitIds: ['sec-07'],
      skillIds: ['cyber.sample.analysis'],
      description: 'تحليل بيانات عينة غير تنفيذية أو محاكاة آمنة.',
    ),
    SecurityLabScenario(
      id: 'cloud-01',
      title: 'تقييم إعدادات السحابة',
      type: SecurityLabScenarioType.cloudConfiguration,
      courseId: 'cloud-security',
      knowledgeUnitIds: ['sec-08'],
      skillIds: ['cyber.cloud.assessment'],
      description: 'تقييم موارد سحابية وهمية واكتشاف سوء التهيئة.',
    ),
    SecurityLabScenario(
      id: 'team-01',
      title: 'محاكاة فريقين دفاعيين',
      type: SecurityLabScenarioType.teamSimulation,
      courseId: 'red-blue-team',
      knowledgeUnitIds: ['sec-09'],
      skillIds: ['cyber.team.response'],
      description: 'محاكاة فريقين داخل نطاق معزول مع قياس الاكتشاف والاستجابة.',
    ),
  ];

  static SecurityLabScenario? byId(String id) {
    for (final scenario in scenarios) {
      if (scenario.id == id) return scenario;
    }
    return null;
  }
}

class SmartSecurityLabEngine {
  const SmartSecurityLabEngine();

  SecurityLabPlan plan({
    required String scenarioId,
    required String assetId,
    SecurityLabAuthorization? authorization,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now().toUtc();
    final scenario = SmartSecurityLabCatalog.byId(scenarioId);
    if (scenario == null) throw ArgumentError('سيناريو المختبر غير معروف.');
    if (assetId.trim().isEmpty) {
      return SecurityLabPlan(
        scenario: scenario,
        assetId: assetId,
        phases: const [],
        status: SecurityLabStatus.blocked,
        reason: 'يجب تحديد أصل مختبري واضح.',
      );
    }
    if (authorization == null || !authorization.validFor(assetId, current)) {
      return SecurityLabPlan(
        scenario: scenario,
        assetId: assetId,
        phases: const [],
        status: SecurityLabStatus.blocked,
        reason: 'لا يوجد تفويض صالح لهذا الأصل.',
      );
    }
    return SecurityLabPlan(
      scenario: scenario,
      assetId: assetId,
      phases: SecurityLabPhase.values,
      status: SecurityLabStatus.ready,
      reason: 'النطاق التدريبي محدد ومصرح به.',
    );
  }

  SecurityLabEvaluation evaluate(SecurityLabSubmission submission) {
    final feedback = <String>[];
    var score = 0.0;
    if (submission.completedPhases.contains(SecurityLabPhase.scope) &&
        submission.completedPhases.contains(SecurityLabPhase.assetInventory)) {
      score += 20;
    } else {
      feedback.add('أكمل تحديد النطاق وجرد الأصل.');
    }
    if (submission.evidence.isNotEmpty &&
        submission.completedPhases.contains(SecurityLabPhase.evidence)) {
      score += 20;
    } else {
      feedback.add('أضف أدلة قابلة للمراجعة.');
    }
    if (submission.findings.isNotEmpty &&
        submission.completedPhases.contains(SecurityLabPhase.finding)) {
      score += 20;
    } else {
      feedback.add('سجل النتائج واربطها بالمعرفة والمهارات.');
    }
    if (submission.remediation.isNotEmpty &&
        submission.completedPhases.contains(SecurityLabPhase.remediation)) {
      score += 20;
    } else {
      feedback.add('وثق المعالجة قبل التحقق.');
    }
    if (submission.completedPhases.contains(SecurityLabPhase.verification) &&
        submission.remediationComplete &&
        submission.verificationPassed) {
      score += 20;
    } else {
      feedback.add('لا تكتمل مرحلة التحقق قبل اكتمال المعالجة.');
    }

    final skillEvidence = <String>{
      for (final finding in submission.findings) ...finding.skillIds,
    }.toList(growable: false);

    final awaitingRemediation = submission.findings.isNotEmpty &&
        (!submission.remediationComplete || !submission.verificationPassed);

    return SecurityLabEvaluation(
      status: score == 100
          ? SecurityLabStatus.completed
          : awaitingRemediation
              ? SecurityLabStatus.awaitingRemediation
              : SecurityLabStatus.inProgress,
      score: score,
      skillEvidence: skillEvidence,
      feedback: List.unmodifiable(feedback),
      nextPhase: score == 100
          ? SecurityLabPhase.report
          : awaitingRemediation
              ? SecurityLabPhase.remediation
              : SecurityLabPhase.values.firstWhere(
                  (phase) => !submission.completedPhases.contains(phase),
                  orElse: () => SecurityLabPhase.report,
                ),
    );
  }
}
