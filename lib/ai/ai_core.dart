/// Application-level contract for TOFAN AI Core.
///
/// The Flutter client depends on this contract, not on a specific provider.
/// Provider credentials and network calls remain outside the student app.
abstract interface class AiCore {
  Future<AiResponse> generate(AiRequest request);
}

/// Provider-agnostic execution modes. Local is the default and requires no key.
enum AiExecutionMode {
  local,
  openAi,
  gemini,
}

class AiRequest {
  const AiRequest({
    required this.systemInstruction,
    required this.userMessage,
    this.context = const <String, String>{},
  });

  final String systemInstruction;
  final String userMessage;
  final Map<String, String> context;
}

class AiResponse {
  const AiResponse({
    required this.text,
    this.provider = 'unknown',
    this.model = 'unknown',
  });

  final String text;
  final String provider;
  final String model;
}
