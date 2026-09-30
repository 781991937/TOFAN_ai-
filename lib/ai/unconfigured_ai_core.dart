import 'ai_core.dart';

/// Safe default used by the Flutter foundation until a backend AI gateway
/// is connected. It never exposes provider credentials or fabricates answers.
class UnconfiguredAiCore implements AiCore {
  const UnconfiguredAiCore();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    return const AiResponse(
      text: 'لم يتم ربط بوابة الذكاء الاصطناعي بالخادم بعد.',
      provider: 'unconfigured',
      model: 'unconfigured',
    );
  }
}
