import '../data/academic/academic_library_security.dart';
import 'academic_knowledge_engine.dart';

enum AbqariCyberMode { observe, simulate, defend }

enum AbqariCyberAction {
  inspectThreat,
  simulateAttack,
  isolateAsset,
  blockIndicator,
  runSecurityAssessment,
}

class AbqariCyberCommand {
  const AbqariCyberCommand({
    required this.originalCommand,
    required this.mode,
    required this.action,
    required this.target,
    required this.reason,
    required this.requiresApproval,
  });

  final String originalCommand;
  final AbqariCyberMode mode;
  final AbqariCyberAction action;
  final String target;
  final String reason;
  final bool requiresApproval;
}

class AbqariCyberResult {
  const AbqariCyberResult({
    required this.command,
    required this.libraryKnowledge,
    required this.steps,
    required this.blocked,
  });

  final AbqariCyberCommand command;
  final List<String> libraryKnowledge;
  final List<String> steps;
  final bool blocked;
}

/// Interprets natural-language cyber commands, but executes only bounded,
/// authorized simulation/defensive operations. It never exposes a raw shell,
/// arbitrary network client, exploit runner, or unrestricted tool.
class AbqariCyberCommandEngine {
  const AbqariCyberCommandEngine({
    this.knowledgeEngine = const AcademicKnowledgeEngine(),
  });

  final AcademicKnowledgeEngine knowledgeEngine;

  AbqariCyberCommand parse(String command) {
    final normalized = command.trim().toLowerCase();
    final attack = normalized.contains('هاجم') ||
        normalized.contains('هجوم') ||
        normalized.contains('attack');
    final defend = normalized.contains('دافع') ||
        normalized.contains('احم') ||
        normalized.contains('defend') ||
        normalized.contains('protect');
    final target = _extractTarget(command);

    if (attack && defend) {
      return AbqariCyberCommand(
        originalCommand: command,
        mode: AbqariCyberMode.simulate,
        action: AbqariCyberAction.simulateAttack,
        target: target,
        reason: 'تنفيذ هجوم حقيقي غير مسموح؛ يتم تحويل الأمر إلى محاكاة هجومية دفاعية داخل بيئة معزولة.',
        requiresApproval: true,
      );
    }
    if (attack) {
      return AbqariCyberCommand(
        originalCommand: command,
        mode: AbqariCyberMode.simulate,
        action: AbqariCyberAction.simulateAttack,
        target: target,
        reason: 'الأمر الهجومي يتحول إلى اختبار محاكاة مصرح به بدل استهداف نظام حقيقي.',
        requiresApproval: true,
      );
    }
    if (defend) {
      return AbqariCyberCommand(
        originalCommand: command,
        mode: AbqariCyberMode.defend,
        action: AbqariCyberAction.isolateAsset,
        target: target,
        reason: 'بدء استجابة دفاعية محلية على الأصل المحدد.',
        requiresApproval: false,
      );
    }
    return AbqariCyberCommand(
      originalCommand: command,
      mode: AbqariCyberMode.observe,
      action: AbqariCyberAction.inspectThreat,
      target: target,
      reason: 'لم يتضمن الأمر تفويضًا لعملية هجومية أو دفاعية.',
      requiresApproval: false,
    );
  }

  AbqariCyberResult execute(AbqariCyberCommand command) {
    final knowledge = knowledgeEngine
        .search('cybersecurity threat detection incident response network security')
        .take(5)
        .map((item) => item.title)
        .toList(growable: false);

    if (command.action == AbqariCyberAction.simulateAttack) {
      return AbqariCyberResult(
        command: command,
        libraryKnowledge: knowledge,
        blocked: false,
        steps: const [
          'تحقق من أن الهدف جزء من مختبر محاكاة مصرح به.',
          'بناء سيناريو تهديد افتراضي من المعرفة الأمنية في المكتبة.',
          'تنفيذ خطوات الهجوم على نموذج محاكاة فقط.',
          'قياس الاكتشاف والمنع والاستجابة.',
          'تسجيل النتائج كخبرة تجريبية منفصلة عن المعرفة الأكاديمية الأصلية.',
        ],
      );
    }

    if (command.action == AbqariCyberAction.isolateAsset) {
      return AbqariCyberResult(
        command: command,
        libraryKnowledge: knowledge,
        blocked: false,
        steps: const [
          'تحديد الأصل المتأثر داخل البيئة المحلية.',
          'تطبيق عزل محاكى للأصل.',
          'جمع مؤشرات الحادث دون تعديل المعرفة الأكاديمية.',
          'تقييم الاستجابة وفق مبادئ الأمن الموجودة في المكتبة.',
        ],
      );
    }

    return AbqariCyberResult(
      command: command,
      libraryKnowledge: knowledge,
      blocked: false,
      steps: const ['تحليل التهديد دون تنفيذ تأثير خارجي.'],
    );
  }

  bool isLibraryGuarded(LibrarySecurityRole role) =>
      role == LibrarySecurityRole.knowledgeAgent ||
      role == LibrarySecurityRole.projectAgent ||
      role == LibrarySecurityRole.securityAdmin;

  String _extractTarget(String command) {
    final match = RegExp(r'(?:على|ضد|target|against)\\s+([^،,.!؟]+)',
            caseSensitive: false)
        .firstMatch(command);
    return match?.group(1)?.trim() ?? 'simulation-lab';
  }
}
