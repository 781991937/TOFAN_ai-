import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/ai_core.dart';
import '../../ai/unconfigured_ai_core.dart';

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
  const MainManagerAgent(this.core);

  final AiCore core;

  @override
  AiAgentRole get role => AiAgentRole.mainManager;

  @override
  Future<AiAgentResponse> handle(AiAgentRequest request) async {
    final response = await core.generate(
      AiRequest(
        systemInstruction:
            'أنت مدير النواة الذكية TOFAN AI. نسّق الطلب ضمن نطاقه الأكاديمي ولا تنفذ وظيفة وكيل متخصص بنفسك.',
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
