import 'package:flutter_test/flutter_test.dart';
import 'package:tofan_ai/ai/ai_core.dart';
import 'package:tofan_ai/services/ai/ai_manager.dart';
import 'package:tofan_ai/services/ai/ai_models.dart';
import 'package:tofan_ai/services/ai/ai_provider.dart';

class _FakeCore implements AiCore {
  AiRequest? seen;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    seen = request;
    return const AiResponse(text: 'local response', provider: 'fake');
  }
}

void main() {
  test(
    'AIManager routes through AiCore without provider credentials',
    () async {
      final core = _FakeCore();
      final manager = AIManager(core: core);

      final result = await manager.sendPrompt(
        'اشرح الرسم البياني',
        history: const [AIChatMessage(role: 'user', content: 'السؤال السابق')],
        override: AIProvider.openai,
      );

      expect(result, 'local response');
      expect(core.seen?.userMessage, 'اشرح الرسم البياني');
      expect(core.seen?.context['conversation'], contains('السؤال السابق'));
    },
  );
}
