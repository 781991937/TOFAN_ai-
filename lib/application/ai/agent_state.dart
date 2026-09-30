import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/ai_core.dart';
import '../../ai/unconfigured_ai_core.dart';
import 'student_ai_context.dart';

enum AiAgentRole {
  mainManager,
  academicTutor,
  assessment,
  knowledge,
  skills,
  project,
  fileDocument,
  progressAnalyst,
  translationTerminology,
}

class AiAgentRequest {
  const AiAgentRequest({
    required this.role,
    required this.request,
    this.context = const <String, String>{},
  });

  final AiAgentRole role;
  final String request;
  final Map<String, String> context;
}

class AiAgentResponse {
  const AiAgentResponse({
    required this.role,
    required this.text,
  });

  final AiAgentRole role;
  final String text;
}

abstract interface class AiAgent {
  AiAgentRole get role;
  Future<AiAgentResponse> handle(AiAgentRequest request);
}

class MainManagerAgent implements AiAgent {
  const MainManagerAgent(this.core, this.studentContext);

  final AiCore core;
  final StudentAiContext studentContext;

  @override
  AiAgentRole get role => AiAgentRole.mainManager;

  @override
  Future<AiAgentResponse> handle(AiAgentRequest request) async {
    if (request.role != AiAgentRole.mainManager) {
      throw ArgumentError('Main Manager cannot execute a specialized agent request.');
    }
    final response = await core.generate(
      AiRequest(
        systemInstruction:
            'أنت مدير النواة الذكية TOFAN AI. نسّق الطلب ضمن نطاقه الأكاديمي وحدد الوكيل المتخصص المناسب، ولا تنفذ وظيفة وكيل متخصص بنفسك.',
        userMessage: request.request,
        context: {
          ...studentContext.toMap(),
          ...request.context,
        },
      ),
    );
    return AiAgentResponse(role: role, text: response.text);
  }
}

class SpecializedAgentRegistry {
  const SpecializedAgentRegistry(this.agents);

  final Map<AiAgentRole, AiAgent> agents;

  AiAgent? operatorFor(AiAgentRole role) => agents[role];
}

final specializedAgentRegistryProvider =
    Provider<SpecializedAgentRegistry>((ref) {
  final core = ref.watch(aiCoreProvider);
  final context = ref.watch(studentAiContextProvider).toMap();
  return SpecializedAgentRegistry({
    AiAgentRole.academicTutor: GenericSpecializedAgent(
      core,
      AiAgentRole.academicTutor,
      'المعلم الأكاديمي: اشرح المفاهيم الأكاديمية المعتمدة للطالب دون اختلاق محتوى غير متوفر.',
    ),
    AiAgentRole.assessment: GenericSpecializedAgent(
      core,
      AiAgentRole.assessment,
      'وكيل التقييم: تعامل مع التقييم والنتائج وفق بيانات النظام دون اختلاق درجات.',
    ),
    AiAgentRole.knowledge: GenericSpecializedAgent(
      core,
      AiAgentRole.knowledge,
      'وكيل المعرفة: نظّم حالة المعرفة المستندة إلى بيانات التعلم والتقييم.',
    ),
    AiAgentRole.skills: GenericSpecializedAgent(
      core,
      AiAgentRole.skills,
      'وكيل المهارات: تعامل مع تحديثات المهارات والقدرات المسجلة في النظام.',
    ),
    AiAgentRole.project: GenericSpecializedAgent(
      core,
      AiAgentRole.project,
      'وكيل المشاريع: تعامل مع المشاريع الأكاديمية الموجودة في الكتالوج دون اختلاق مشروع.',
    ),
    AiAgentRole.fileDocument: GenericSpecializedAgent(
      core,
      AiAgentRole.fileDocument,
      'وكيل الملفات: تعامل مع الملفات الأكاديمية المتاحة فقط.',
    ),
    AiAgentRole.progressAnalyst: GenericSpecializedAgent(
      core,
      AiAgentRole.progressAnalyst,
      'محلل التقدم: حلل بيانات تقدم الطالب المسجلة دون اختلاق بيانات.',
    ),
    AiAgentRole.translationTerminology: GenericSpecializedAgent(
      core,
      AiAgentRole.translationTerminology,
      'وكيل الترجمة والمصطلحات: تعامل مع الترجمة والمصطلحات الأكاديمية.',
    ),
  });
});

class GenericSpecializedAgent implements AiAgent {
  const GenericSpecializedAgent(this.core, this.role, this.instruction);

  final AiCore core;
  final AiAgentRole role;
  final String instruction;

  @override
  Future<AiAgentResponse> handle(AiAgentRequest request) async {
    if (request.role != role) {
      throw ArgumentError('Request role does not match this agent.');
    }
    final response = await core.generate(
      AiRequest(
        systemInstruction: instruction,
        userMessage: request.request,
        context: request.context,
      ),
    );
    return AiAgentResponse(role: role, text: response.text);
  }
}

final aiCoreProvider = Provider<AiCore>((ref) {
  return const UnconfiguredAiCore();
});

final mainManagerAgentProvider = Provider<AiAgent>((ref) {
  return MainManagerAgent(ref.watch(aiCoreProvider));
});
