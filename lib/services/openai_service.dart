import 'package:dio/dio.dart';

/// Thin client wrapper for the OpenAI API.
///
/// Requires an API key to be supplied at call time. Keys should be
/// retrieved from [SecureStorageService] and never hard-coded.
class OpenAiService {
  OpenAiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.openai.com/v1',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
            ));

  final Dio _dio;

  /// Sends a chat completion request. [apiKey] must be provided by the
  /// caller (loaded from secure storage).
  Future<String> sendChatMessage({
    required String apiKey,
    required List<Map<String, String>> messages,
    String model = 'gpt-4o-mini',
  }) async {
    if (apiKey.isEmpty) {
      throw StateError('OpenAI API key is not configured.');
    }

    final response = await _dio.post(
      '/chat/completions',
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': model,
        'messages': messages,
      },
    );

    final choices = response.data['choices'] as List<dynamic>;
    return choices.first['message']['content'] as String;
  }

  /// Generates an image using the OpenAI Images API.
  Future<String> generateImage({
    required String apiKey,
    required String prompt,
    String model = 'dall-e-3',
    String size = '1024x1024',
  }) async {
    if (apiKey.isEmpty) {
      throw StateError('OpenAI API key is not configured.');
    }

    final response = await _dio.post(
      '/images/generations',
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': model,
        'prompt': prompt,
        'size': size,
        'n': 1,
      },
    );

    final data = response.data['data'] as List<dynamic>;
    return data.first['url'] as String;
  }
}
