import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'ai_models.dart';
import 'ai_provider.dart';

/// Handles all HTTP communication with the OpenAI Chat Completions API.
///
/// Includes retry-with-backoff and timeout handling so callers (the
/// [AIManager]) can treat this as a reliable, best-effort transport.
class OpenAIService {
  OpenAIService({Dio? dio, this.maxRetries = 2, this.requestTimeout = const Duration(seconds: 30)})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.openai.com/v1',
              connectTimeout: const Duration(seconds: 15),
            ));

  final Dio _dio;
  final int maxRetries;
  final Duration requestTimeout;

  static const String defaultModel = 'gpt-4o-mini';

  Future<AIResponse> sendChat({
    required String apiKey,
    required List<AIChatMessage> messages,
    String model = defaultModel,
  }) async {
    if (apiKey.isEmpty) {
      throw const AIServiceException(
        message: 'OpenAI API key is not configured.',
        provider: AIProvider.openai,
      );
    }

    Object? lastError;
    int? lastStatusCode;

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        developer.log(
          'Sending chat request (attempt ${attempt + 1}/${maxRetries + 1})',
          name: 'OpenAIService',
        );

        final response = await _dio
            .post(
              '/chat/completions',
              options: Options(headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              }),
              data: {
                'model': model,
                'messages': messages.map((m) => m.toMap()).toList(),
              },
            )
            .timeout(requestTimeout);

        final choices = response.data['choices'] as List<dynamic>;
        final content = choices.first['message']['content'] as String;

        developer.log('Received response successfully', name: 'OpenAIService');
        return AIResponse(content: content, provider: AIProvider.openai);
      } on DioException catch (error) {
        lastError = error;
        lastStatusCode = error.response?.statusCode;

        developer.log(
          'Request failed: ${error.message} (status: $lastStatusCode)',
          name: 'OpenAIService',
          error: error,
        );

        // Do not retry on client errors such as bad auth or bad request.
        if (lastStatusCode != null && lastStatusCode >= 400 && lastStatusCode < 500) {
          break;
        }
      } catch (error) {
        lastError = error;
        developer.log('Unexpected error: $error', name: 'OpenAIService', error: error);
      }

      if (attempt < maxRetries) {
        final backoff = Duration(milliseconds: 400 * (attempt + 1));
        await Future.delayed(backoff);
      }
    }

    throw AIServiceException(
      message: 'Failed to reach OpenAI after ${maxRetries + 1} attempt(s): $lastError',
      provider: AIProvider.openai,
      statusCode: lastStatusCode,
      cause: lastError,
    );
  }

  Future<String> generateImage({
    required String apiKey,
    required String prompt,
    String model = 'dall-e-3',
    String size = '1024x1024',
  }) async {
    if (apiKey.isEmpty) {
      throw const AIServiceException(
        message: 'OpenAI API key is not configured.',
        provider: AIProvider.openai,
      );
    }

    try {
      final response = await _dio
          .post(
            '/images/generations',
            options: Options(headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            }),
            data: {'model': model, 'prompt': prompt, 'size': size, 'n': 1},
          )
          .timeout(requestTimeout);

      final data = response.data['data'] as List<dynamic>;
      return data.first['url'] as String;
    } on DioException catch (error) {
      developer.log('Image generation failed: ${error.message}', name: 'OpenAIService', error: error);
      throw AIServiceException(
        message: 'Failed to generate image: ${error.message}',
        provider: AIProvider.openai,
        statusCode: error.response?.statusCode,
        cause: error,
      );
    }
  }
}
