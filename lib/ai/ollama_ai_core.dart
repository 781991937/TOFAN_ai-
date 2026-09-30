import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_core.dart';

/// Configuration for a local Ollama-compatible LLM server.
///
/// No API key is required. The endpoint can point to Ollama on the same
/// machine or to a trusted local network host.
class LocalAiConfig {
  const LocalAiConfig({
    this.baseUrl = 'http://127.0.0.1:11434',
    this.model = 'qwen3:4b',
    this.timeout = const Duration(seconds: 60),
  });

  final String baseUrl;
  final String model;
  final Duration timeout;
}

/// Local generative AI implementation using an Ollama-compatible endpoint.
///
/// The application still depends only on [AiCore]. If the local server is
/// unavailable, a clear error response is returned instead of fabricating AI
/// output or requiring an external provider key.
class OllamaAiCore implements AiCore {
  OllamaAiCore({
    this.config = const LocalAiConfig(),
    http.Client? client,
  }) : _client = client ?? http.Client();

  final LocalAiConfig config;
  final http.Client _client;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    final uri = Uri.parse(
      '${config.baseUrl.replaceFirst(RegExp(r'/*\$'), '')}/api/chat',
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': config.model,
              'stream': false,
              'messages': [
                {
                  'role': 'system',
                  'content': _systemPrompt(request),
                },
                {
                  'role': 'user',
                  'content': request.userMessage,
                },
              ],
            }),
          )
          .timeout(config.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AiResponse(
          text: 'تعذر تشغيل النموذج المحلي. تأكد من تشغيل خادم Ollama والنموذج المحلي.',
          provider: 'local',
          model: config.model,
        );
      }

      final decoded = jsonDecode(response.body);
      final message = decoded is Map<String, dynamic>
          ? decoded['message']
          : null;
      final text = message is Map<String, dynamic>
          ? message['content']
          : null;

      if (text is! String || text.trim().isEmpty) {
        return AiResponse(
          text: 'لم يُرجع النموذج المحلي استجابة صالحة.',
          provider: 'local',
          model: config.model,
        );
      }

      return AiResponse(
        text: text.trim(),
        provider: 'local',
        model: config.model,
      );
    } catch (_) {
      return AiResponse(
        text: 'النموذج المحلي غير متاح حاليًا. شغّل خادم Ollama محليًا ثم أعد المحاولة.',
        provider: 'local',
        model: config.model,
      );
    }
  }

  String _systemPrompt(AiRequest request) {
    final context = request.context.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    return [
      request.systemInstruction,
      'التزم ببيانات الطالب التالية فقط ولا تخترع بيانات أكاديمية:',
      context,
    ].join('\n\n');
  }
}
