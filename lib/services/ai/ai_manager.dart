import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../ai/ai_core.dart';
import '../../ai/local_first_ai_core.dart';
import 'ai_models.dart';
import 'ai_provider.dart';

/// Compatibility facade over the provider-agnostic [AiCore] contract.
///
/// This class intentionally does not accept or read provider API keys. External
/// providers must be reached through a configured backend [AiCore]; local-first
/// remains the safe default.
class AIManager {
  AIManager({AiCore? core}) : _core = core ?? LocalFirstAiCore();

  final AiCore _core;

  Future<String> sendPrompt(
    String prompt, {
    List<AIChatMessage> history = const [],
    AIProvider override = AIProvider.auto,
  }) async {
    final historyText = history
        .map((message) => '${message.role}: ${message.content}')
        .join('\n');
    final request = AiRequest(
      systemInstruction:
          'أجب بدقة، واذكر حدود المعرفة عند الحاجة. وضع المزود الحالي: ${override.label}.',
      userMessage: prompt,
      context: historyText.isEmpty ? const {} : {'conversation': historyText},
    );
    final response = await _core.generate(request);
    return response.text;
  }

  Stream<String> streamPrompt(
    String prompt, {
    List<AIChatMessage> history = const [],
    AIProvider override = AIProvider.auto,
  }) {
    throw UnimplementedError(
      'Streaming is not implemented yet. Use sendPrompt() for now.',
    );
  }
}

final aiCoreProvider = Provider<AiCore>((ref) => LocalFirstAiCore());

final aiManagerProvider = Provider<AIManager>((ref) {
  return AIManager(core: ref.watch(aiCoreProvider));
});

/// Kept as a UI preference only; it cannot select a client-side provider or
/// expose provider credentials. A configured backend decides the provider.
final aiManualOverrideProvider = StateProvider<AIProvider?>((ref) => null);
