import '../data/academic/academic_library_security.dart';
import '../data/academic/academic_library_security_catalog.dart';
import 'academic_knowledge_engine.dart';
import 'abqari_models.dart';
import 'cyber_command_engine.dart';
import 'project_engine.dart';

enum AbqariTaskKind { academic, project, cybersecurity, programming, personalSafety, translation, general }
enum AbqariRiskLevel { low, guarded, high }

class AbqariTask {
  const AbqariTask({required this.request, required this.kind, required this.risk, required this.requiresApproval});
  final String request;
  final AbqariTaskKind kind;
  final AbqariRiskLevel risk;
  final bool requiresApproval;
}

class AbqariAgentResult {
  const AbqariAgentResult({required this.task, required this.summary, required this.knowledge, required this.actions, required this.blocked, required this.approvalRequired});
  final AbqariTask task;
  final String summary;
  final List<AbqariKnowledgeItem> knowledge;
  final List<String> actions;
  final bool blocked;
  final bool approvalRequired;
}

/// Primary multi-task orchestration boundary for TOFAN AL-ABQARI.
/// It routes requests, applies policy before action, and retrieves academic
/// knowledge through the protected library gateway.
class TofanAbqariAgent {
  const TofanAbqariAgent({
    this.knowledgeEngine = const AcademicKnowledgeEngine(),
    this.projectEngine = const AbqariProjectEngine(),
    this.cyberEngine = const AbqariCyberCommandEngine(),
  });

  final AcademicKnowledgeEngine knowledgeEngine;
  final AbqariProjectEngine projectEngine;
  final AbqariCyberCommandEngine cyberEngine;

  AbqariTask classify(String request) {
    final text = request.trim().toLowerCase();
    final cyber = _containsAny(text, ['هجوم', 'هاجم', 'اختراق', 'أمن سيبراني', 'attack', 'hack']);
    final safety = _containsAny(text, ['خطر', 'تهديد', 'يهاجم', 'اعتداء', 'يحاول إيذاء', 'threat', 'danger']);
    final project = _containsAny(text, ['مشروع', 'ابن', 'بناء نظام', 'project', 'build']);
    final programming = _containsAny(text, ['كود', 'برمج', 'python', 'dart', 'flutter', 'code']);
    final translation = _containsAny(text, ['ترجم', 'مصطلح', 'translation', 'term']);
    final academic = _containsAny(text, ['اشرح', 'درس', 'مقرر', 'محاضرة', 'تعلم', 'مفهوم', 'شرح', 'study']);

    if (safety) return AbqariTask(request: request, kind: AbqariTaskKind.personalSafety, risk: AbqariRiskLevel.high, requiresApproval: true);
    if (cyber) return AbqariTask(request: request, kind: AbqariTaskKind.cybersecurity, risk: AbqariRiskLevel.guarded, requiresApproval: text.contains('هجوم') || text.contains('هاجم') || text.contains('attack'));
    if (project) return AbqariTask(request: request, kind: AbqariTaskKind.project, risk: AbqariRiskLevel.guarded, requiresApproval: false);
    if (programming) return AbqariTask(request: request, kind: AbqariTaskKind.programming, risk: AbqariRiskLevel.guarded, requiresApproval: false);
    if (translation) return AbqariTask(request: request, kind: AbqariTaskKind.translation, risk: AbqariRiskLevel.low, requiresApproval: false);
    if (academic) return AbqariTask(request: request, kind: AbqariTaskKind.academic, risk: AbqariRiskLevel.low, requiresApproval: false);
    return AbqariTask(request: request, kind: AbqariTaskKind.general, risk: AbqariRiskLevel.low, requiresApproval: false);
  }

  AbqariAgentResult handle(String request, {LibrarySecurityRole role = LibrarySecurityRole.knowledgeAgent}) {
    final task = classify(request);
    final knowledge = _guardedKnowledge(task.request, role);

    switch (task.kind) {
      case AbqariTaskKind.project:
        final plan = projectEngine.plan(AbqariProjectRequest(idea: task.request));
        return AbqariAgentResult(task: task, summary: 'تم تحويل الطلب إلى خطة مشروع مترابطة مع المعرفة والمهارات والفجوات.', knowledge: plan.knowledge, actions: plan.phases, blocked: false, approvalRequired: task.requiresApproval);
      case AbqariTaskKind.cybersecurity:
        final command = cyberEngine.parse(task.request);
        final result = cyberEngine.execute(command);
        return AbqariAgentResult(task: task, summary: result.blocked ? 'تم حظر العملية.' : 'تم توجيه الطلب عبر طبقة الأمن إلى استجابة مقيدة.', knowledge: knowledge, actions: result.steps, blocked: result.blocked, approvalRequired: command.requiresApproval);
      case AbqariTaskKind.personalSafety:
        return AbqariAgentResult(task: task, summary: 'الأولوية حماية الشخص وتقييم الخطر، لا تنفيذ انتقام أو اعتداء.', knowledge: knowledge, actions: const [
          'تقييم مستوى الخطر والمكان والوقت من المعلومات التي يقدمها المستخدم.',
          'اقتراح الابتعاد إلى مكان آمن وطلب المساعدة المحلية عند وجود خطر مباشر.',
          'تنظيم المعلومات والأدلة التي يملكها المستخدم دون تعريض الشخص للخطر.',
          'أي إجراء خارجي عالي التأثير يحتاج تفويضًا صريحًا وموافقة المستخدم.',
        ], blocked: false, approvalRequired: true);
      case AbqariTaskKind.academic:
      case AbqariTaskKind.programming:
      case AbqariTaskKind.translation:
      case AbqariTaskKind.general:
        return AbqariAgentResult(task: task, summary: 'تم توجيه الطلب إلى طبقة المعرفة المناسبة مع الالتزام بصلاحيات المكتبة.', knowledge: knowledge, actions: const [
          'استرجاع المعرفة المصرح بها.',
          'ربط المفاهيم بالمهارات والتطبيقات.',
          'إرجاع النتيجة دون تعديل المعرفة الأكاديمية الأصلية.',
        ], blocked: false, approvalRequired: task.requiresApproval);
    }
  }

  List<AbqariKnowledgeItem> _guardedKnowledge(String request, LibrarySecurityRole role) {
    final domains = AcademicLibrarySecurityCatalog.domains.where(
      (domain) => AcademicLibrarySecurityCatalog.policy.canAccess(role, domain.id, LibraryAccessOperation.search),
    );
    if (domains.isEmpty) return const <AbqariKnowledgeItem>[];
    final allowedAreas = <String>{for (final domain in domains) ...domain.knowledgeAreaIds};
    return knowledgeEngine.search(request).where((item) => item.knowledgeAreaIds.any(allowedAreas.contains)).toList(growable: false);
  }

  bool _containsAny(String text, List<String> terms) => terms.any(text.contains);
}
