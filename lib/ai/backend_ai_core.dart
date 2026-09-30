import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_core.dart';
import 'local_first_ai_core.dart';

/// Secure backend gateway adapter.
///
/// The Flutter client sends the request to TOFAN's backend gateway.
/// Provider credentials must stay on the server; this class never accepts
/// or stores an OpenAI/Gemini API key.
class BackendAiCore implements AiCore {
  const BackendAiCore({
    required this.endpoint,
    required this.provider,
    this.timeout = const Duration(seconds: 60),
  });

  final String endpoint;
  final AiExecutionMode provider;
  final Duration timeout;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    if (endpoint.trim().isEmpty) {
      return const AiResponse(
        text: 'بوابة الذكاء الاصطناعي الخارجية غير مهيأة بعد. استخدم الوضع المحلي.',
        provider: 'gateway',
        model: 'unconfigured',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'provider': provider.name,
              'system_instruction': request.systemInstruction,
              'user_message': request.userMessage,
              'context': request.context,
            }),
          )
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const AiResponse(
          text: 'تعذر الوصول إلى بوابة الذكاء الاصطناعي. استخدم الوضع المحلي.',
          provider: 'gateway',
          model: 'unavailable',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['text'] is! String) {
        return const AiResponse(
          text: 'استجابة بوابة الذكاء الاصطناعي غير صالحة. استخدم الوضع المحلي.',
          provider: 'gateway',
          model: 'invalid',
        );
      }

      return AiResponse(
        text: decoded['text'] as String,
        provider: (decoded['provider'] as String?) ?? provider.name,
        model: (decoded['model'] as String?) ?? 'gateway',
      );
    } catch (_) {
      return const AiResponse(
        text: 'تعذر تشغيل بوابة الذكاء الاصطناعي. استخدم الوضع المحلي.',
        provider: 'gateway',
        model: 'unavailable',
      );
    }
  }
}


/// Uses the secure gateway when configured and keeps the local-first fallback.
class GatewayFirstAiCore implements AiCore {
  const GatewayFirstAiCore({
    required this.endpoint,
    required this.provider,
  });

  final String endpoint;
  final AiExecutionMode provider;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    final gateway = BackendAiCore(endpoint: endpoint, provider: provider);
    final response = await gateway.generate(request);
    if (response.provider == 'gateway') {
      return LocalFirstAiCore().generate(request);
    }
    return response;
  }
}
