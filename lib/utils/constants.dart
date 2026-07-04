/// App-wide constants for TOFAN AI.
class AppConstants {
  AppConstants._();

  static const String appName = 'TOFAN AI';

  // Secure storage keys
  static const String openAiApiKeyStorageKey = 'openai_api_key';
  static const String geminiApiKeyStorageKey = 'gemini_api_key';

  // Shared preferences keys
  static const String themeModeKey = 'theme_mode';
  static const String selectedAiProviderKey = 'selected_ai_provider';

  // Database
  static const String databaseName = 'tofan_ai.db';
  static const int databaseVersion = 1;
  static const String chatMessagesTable = 'chat_messages';
  static const String conversationsTable = 'conversations';
}

/// Supported AI providers for TOFAN AI.
enum AiProvider { openAi, gemini }

extension AiProviderX on AiProvider {
  String get label => switch (this) {
        AiProvider.openAi => 'OpenAI',
        AiProvider.gemini => 'Google Gemini',
      };

  String get storageValue => switch (this) {
        AiProvider.openAi => 'openai',
        AiProvider.gemini => 'gemini',
      };

  static AiProvider fromStorageValue(String? value) {
    switch (value) {
      case 'gemini':
        return AiProvider.gemini;
      case 'openai':
      default:
        return AiProvider.openAi;
    }
  }
}
