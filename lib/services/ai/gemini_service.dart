import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'ai_models.dart';
import 'ai_provider.dart';

/// Handles all HTTP communication with the Google Gemini generateContent
/// API. Includes retry-with-backoff and timeout handling so callers (the
/// [AIManager]) can treat this as a reliable, best-effort transport.
class GeminiService {
  GeminiService({Dio? dio, this.maxRetries = 2, this.requestTimeout = const Duration(seconds: 30)})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
              connectTimeout: const Duration(seconds: 15),
            ));

  final Dio _dio;
  final int maxRetries;
  final Duration requestTimeout;

  static const String defaultModel = 'gemini-1.5-flash';

  Future<AIResponse> sendChat({
    required String apiKey,
    required List<AIChatMessage> messages,
    String model = defaultModel,
  }) async {
    if (apiKey.isEmpty) {
      throw const AIServiceException(
        message: 'Gemini API key is not configured.',
        provider: AIProvider.gemini,
      );
    }

    final contents = messages
        .map((message) => {
              'role': message.role == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': message.content}
              ],
            })
        .toList();

    Object? lastError;
    int? lastStatusCode;

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        developer.log(
          'Sending chat request (attempt ${attempt + 1}/${maxRetries + 1})',
          name: 'GeminiService',
        );

        final response = await _dio
            .post(
              '/models/$model:generateContent',
              queryParameters: {'key': apiKey},
              data: {'contents': contents},
            )
            .timeout(requestTimeout);

        final candidates = response.data['candidates'] as List<dynamic>;
        final parts = candidates.first['content']['parts'] as List<dynamic>;
        final content = parts.first['text'] as String;

        developer.log('Received response successfully', name: 'GeminiService');
        return AIResponse(content: content, provider: AIProvider.gemini);
      } on DioException catch (error) {
        lastError = error;
        lastStatusCode = error.response?.statusCode;

        developer.log(
          'Request failed: ${error.message} (status: $lastStatusCode)',
          name: 'GeminiService',
          error: error,
        );

        if (lastStatusCode != null && lastStatusCode >= 400 && lastStatusCode < 500) {
          break;
        }
      } catch (error) {
        lastError = error;
        developer.log('Unexpected error: $error', name: 'GeminiService', error: error);
      }

      if (attempt < maxRetries) {
        final backoff = Duration(milliseconds: 400 * (attempt + 1));
        await Future.delayed(backoff);
      }
    }

    throw AIServiceException(
      message: 'Failed to reach Gemini after ${maxRetries + 1} attempt(s): $lastError',
      provider: AIProvider.gemini,
      statusCode: lastStatusCode,
      cause: lastError,
    );
  }
}
