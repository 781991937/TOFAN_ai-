import 'ai_core.dart';
import 'local_ai_core.dart';
import 'ollama_ai_core.dart';

/// Local-first coordinator.
///
/// 1. Tries a real local LLM through Ollama.
/// 2. Falls back to the built-in keyless local core when no local server is
///    available, so the application remains usable without any API key.
class LocalFirstAiCore implements AiCore {
  LocalFirstAiCore({
    this.ollama = const LocalAiConfig(),
    this.fallback = const LocalAiCore(),
  });

  final LocalAiConfig ollama;
  final LocalAiCore fallback;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    final response = await OllamaAiCore(config: ollama).generate(request);

    if (response.provider == 'local' &&
        response.model == ollama.model &&
        !_isUnavailable(response.text)) {
      return response;
    }

    return fallback.generate(request);
  }

  bool _isUnavailable(String text) {
    return text.contains('غير متاح') ||
        text.contains('تعذر تشغيل') ||
        text.contains('استجابة صالحة');
  }
}
