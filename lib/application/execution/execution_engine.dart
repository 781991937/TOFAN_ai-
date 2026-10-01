import '../../domain/execution/execution_models.dart';

/// Coordinates authorization, workspace policy, execution evidence and
/// correction/re-test state. It deliberately does not execute OS commands;
/// a platform adapter must provide the actual sandbox implementation.
class ExecutionEngine {
  const ExecutionEngine();

  bool authorizeTool({
    required ToolContract tool,
    required ToolAuthorization authorization,
  }) {
    if (!authorization.permitsResource(tool.resource)) return false;
    return tool.permissions.every(authorization.permits);
  }

  bool authorizeWorkspace({
    required WorkspaceRequest request,
    required WorkspacePolicy policy,
  }) => policy.allowsCommand(request.command);

  CapabilityVerification verifyCapability({
    required String capabilityId,
    required List<String> requiredSkillIds,
    required List<TestEvidence> evidence,
  }) {
    final passed = evidence.where((item) => item.passed).toList(growable: false);
    final hasRequiredTests = requiredSkillIds.isEmpty
        ? passed.isNotEmpty
        : passed.length >= requiredSkillIds.length;
    final verified = requiredSkillIds.isNotEmpty && hasRequiredTests;
    return CapabilityVerification(
      capabilityId: capabilityId,
      verified: verified,
      requiredSkillIds: List.unmodifiable(requiredSkillIds),
      passedTestIds: List.unmodifiable(passed.map((item) => item.testId)),
      evidence: List.unmodifiable(evidence),
      reason: verified
          ? 'تم إثبات القدرة باختبارات ناجحة وأدلة تنفيذ.'
          : 'لا تكفي حالة إكمال المشروع وحدها لإثبات القدرة؛ يلزم ربط المهارات باختبارات وأدلة ناجحة.',
    );
  }

  CorrectionPlan classifyFailure({
    required String affectedComponent,
    required String error,
  }) {
    final text = error.toLowerCase();
    final errorClass = text.contains('permission') || text.contains('denied')
        ? ErrorClass.authorization
        : text.contains('timeout')
            ? ErrorClass.workspace
            : text.contains('test') || text.contains('assert')
                ? ErrorClass.test
                : text.contains('invalid') || text.contains('validation')
                    ? ErrorClass.validation
                    : ErrorClass.execution;
    return CorrectionPlan(
      errorClass: errorClass,
      affectedComponent: affectedComponent,
      rootCause: error,
      actions: [
        'تثبيت الخطأ كما ظهر دون تغييره إلى نتيجة نجاح.',
        'تطبيق أقل تصحيح ممكن على المكوّن المتأثر.',
        'إعادة الاختبار مع الحفاظ على دليل الفشل السابق.',
      ],
    );
  }
}
