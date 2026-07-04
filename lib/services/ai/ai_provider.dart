/// Identifies which backend should service an AI request.
///
/// [auto] is the default: the [AIRouter] inspects the prompt and decides
/// between [openai] and [gemini] on the caller's behalf. Callers may still
/// pass an explicit [openai] or [gemini] value to force a provider.
enum AIProvider { openai, gemini, auto }

extension AIProviderX on AIProvider {
  String get label {
    switch (this) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.gemini:
        return 'Google Gemini';
      case AIProvider.auto:
        return 'Auto';
    }
  }

  String get storageValue => name;

  static AIProvider fromStorageValue(String? value) {
    return AIProvider.values.firstWhere(
      (provider) => provider.storageValue == value,
      orElse: () => AIProvider.auto,
    );
  }
}
