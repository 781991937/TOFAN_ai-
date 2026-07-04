import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../providers/settings_provider.dart';
import '../secure_storage_service.dart';
import 'ai_models.dart';
import 'ai_provider.dart';
import 'ai_router.dart';
import 'gemini_service.dart' as ai;
import 'openai_service.dart' as ai;

/// Single entry point for the rest of the app to talk to any AI backend.
///
/// [AIManager] hides the decision of *which* provider handles a prompt.
/// Callers pass a prompt (and optional conversation history) and get back
/// a plain [String] reply. By default the [AIRouter] automatically picks
/// OpenAI or Gemini based on the prompt; callers may also force a
/// specific provider via [override].
///
/// If the automatically (or manually) chosen provider fails, the manager
/// falls back to OpenAI once before giving up, per the default fallback
/// rule.
class AIManager {
  AIManager({
    required SecureStorageService secureStorage,
    ai.OpenAIService? openAiService,
    ai.GeminiService? geminiService,
  })  : _secureStorage = secureStorage,
        _openAiService = openAiService ?? ai.OpenAIService(),
        _geminiService = geminiService ?? ai.GeminiService();

  final SecureStorageService _secureStorage;
  final ai.OpenAIService _openAiService;
  final ai.GeminiService _geminiService;

  /// Sends [prompt] (with optional [history]) to the appropriate AI
  /// backend and returns the assistant's reply as plain text.
  ///
  /// [override] forces a specific provider. Leave it as
  /// [AIProvider.auto] (the default) to let the [AIRouter] decide based
  /// on the content of [prompt].
  Future<String> sendPrompt(
    String prompt, {
    List<AIChatMessage> history = const [],
    AIProvider override = AIProvider.auto,
  }) async {
    final chosenProvider =
        override == AIProvider.auto ? AIRouter.decide(prompt) : override;

    developer.log(
      'Routing prompt to ${chosenProvider.label} (override: ${override.label})',
      name: 'AIManager',
    );

    final messages = [...history, AIChatMessage(role: 'user', content: prompt)];

    try {
      final response = await _dispatch(chosenProvider, messages);
      return response.content;
    } on AIServiceException catch (error) {
      developer.log(
        '${chosenProvider.label} failed: ${error.message}. Falling back to OpenAI.',
        name: 'AIManager',
        error: error,
      );

      // Default fallback rule: if the chosen provider isn't already
      // OpenAI, retry once with OpenAI before surfacing the error.
      if (chosenProvider != AIProvider.openai) {
        try {
          final fallback = await _dispatch(AIProvider.openai, messages);
          return fallback.content;
        } on AIServiceException catch (fallbackError) {
          developer.log(
            'Fallback to OpenAI also failed: ${fallbackError.message}',
            name: 'AIManager',
            error: fallbackError,
          );
          rethrow;
        }
      }

      rethrow;
    }
  }

  /// Placeholder for future streaming support (e.g. token-by-token chat
  /// or live voice responses). Not yet implemented by either backend
  /// service, but the signature is ready to be wired in without
  /// changing call sites.
  Stream<String> streamPrompt(
    String prompt, {
    List<AIChatMessage> history = const [],
    AIProvider override = AIProvider.auto,
  }) {
    throw UnimplementedError(
      'Streaming is not implemented yet. Use sendPrompt() for now.',
    );
  }

  Future<AIResponse> _dispatch(
    AIProvider provider,
    List<AIChatMessage> messages,
  ) async {
    switch (provider) {
      case AIProvider.gemini:
        final apiKey = await _secureStorage.getGeminiApiKey();
        return _geminiService.sendChat(apiKey: apiKey ?? '', messages: messages);
      case AIProvider.openai:
      case AIProvider.auto:
        final apiKey = await _secureStorage.getOpenAiApiKey();
        return _openAiService.sendChat(apiKey: apiKey ?? '', messages: messages);
    }
  }
}

final openAIServiceProvider = Provider<ai.OpenAIService>((ref) => ai.OpenAIService());
final geminiAiServiceProvider = Provider<ai.GeminiService>((ref) => ai.GeminiService());

/// Optional manual override for which provider [AIManager] should use.
/// Defaults to `null`, meaning "let the router decide" (auto mode).
/// UI (e.g. a future Settings toggle or the Voice screen) can set this
/// via `ref.read(aiManualOverrideProvider.notifier).state = AIProvider.gemini`.
final aiManualOverrideProvider = StateProvider<AIProvider?>((ref) => null);

final aiManagerProvider = Provider<AIManager>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AIManager(
    secureStorage: secureStorage,
    openAiService: ref.watch(openAIServiceProvider),
    geminiService: ref.watch(geminiAiServiceProvider),
  );
});
