/// Product-wide constants for TOFAN SMART ACADEMY.
class AppConstants {
  AppConstants._();

  static const String appName = 'TOFAN SMART ACADEMY';
  static const String aiName = 'TOFAN AI';
  static const String productName = 'TOFAN AI STUDENT';

  // Temporary local storage keys. Production AI credentials belong on the
  // backend and will be removed from the student client.
  static const String openAiApiKeyStorageKey = 'openai_api_key';
  static const String geminiApiKeyStorageKey = 'gemini_api_key';

  static const String themeModeKey = 'theme_mode';
  static const String selectedAiProviderKey = 'selected_ai_provider';

  static const String databaseName = 'tofan_ai.db';
  static const int databaseVersion = 4;
  static const String chatMessagesTable = 'chat_messages';
  static const String conversationsTable = 'conversations';
  static const String auditEventsTable = 'audit_events';
  static const String auditActorIndex = 'idx_audit_events_actor';
  static const String auditResourceIndex = 'idx_audit_events_resource';
  static const String studentLearningTable = 'student_learning_state';
  static const String experienceMemoryTable = 'experience_memory';
  static const String experienceActorIndex = 'idx_experience_memory_actor';
  static const String experienceCreatedIndex = 'idx_experience_memory_created';
}

/// Supported AI providers during the current migration stage.
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
