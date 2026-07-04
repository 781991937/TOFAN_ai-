import 'ai_provider.dart';

/// A single message exchanged with an AI backend. Mirrors the shape
/// expected by both the OpenAI and Gemini chat APIs (role + content).
class AIChatMessage {
  final String role;
  final String content;

  const AIChatMessage({required this.role, required this.content});

  Map<String, String> toMap() => {'role': role, 'content': content};
}

/// Normalized response returned by any [AIProvider] backend.
class AIResponse {
  final String content;
  final AIProvider provider;

  const AIResponse({required this.content, required this.provider});
}

/// Thrown when a request to an AI backend fails, after retries are
/// exhausted. Carries enough context to decide whether to fall back to
/// another provider.
class AIServiceException implements Exception {
  final String message;
  final AIProvider provider;
  final int? statusCode;
  final Object? cause;

  const AIServiceException({
    required this.message,
    required this.provider,
    this.statusCode,
    this.cause,
  });

  @override
  String toString() =>
      'AIServiceException(provider: ${provider.label}, statusCode: $statusCode, message: $message)';
}
