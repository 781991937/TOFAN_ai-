import 'package:dio/dio.dart';

/// Thin client wrapper for the Google Gemini API.
///
/// Requires an API key to be supplied at call time. Keys should be
/// retrieved from [SecureStorageService] and never hard-coded.
class GeminiService {
  GeminiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
            ));

  final Dio _dio;

  /// Sends a message to a Gemini generative model and returns the reply.
  Future<String> sendChatMessage({
    required String apiKey,
    required List<Map<String, String>> messages,
    String model = 'gemini-1.5-flash',
  }) async {
    if (apiKey.isEmpty) {
      throw StateError('Gemini API key is not configured.');
    }

    final contents = messages
        .map((message) => {
              'role': message['role'] == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': message['content']}
              ],
            })
        .toList();

    final response = await _dio.post(
      '/models/$model:generateContent',
      queryParameters: {'key': apiKey},
      data: {'contents': contents},
    );

    final candidates = response.data['candidates'] as List<dynamic>;
    final parts = candidates.first['content']['parts'] as List<dynamic>;
    return parts.first['text'] as String;
  }
}
