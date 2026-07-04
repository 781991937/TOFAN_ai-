import 'ai_provider.dart';

/// Decides which [AIProvider] should handle a given prompt when the
/// caller has not explicitly picked one (i.e. [AIProvider.auto]).
///
/// Heuristics:
/// - Coding tasks, long/complex prompts, creative writing, and deep
///   reasoning are routed to OpenAI.
/// - Short questions, quick facts, and simple answers are routed to
///   Gemini.
/// - Anything ambiguous falls back to OpenAI.
class AIRouter {
  AIRouter._();

  static const int _shortPromptWordThreshold = 12;
  static const int _longPromptWordThreshold = 40;

  static const List<String> _codingKeywords = [
    'code',
    'function',
    'bug',
    'debug',
    'algorithm',
    'compile',
    'stack trace',
    'refactor',
    'class ',
    'python',
    'dart',
    'flutter',
    'javascript',
    'typescript',
    'sql',
    'regex',
    'api',
    'error:',
    'exception',
  ];

  static const List<String> _creativeKeywords = [
    'write a story',
    'write a poem',
    'poem about',
    'short story',
    'screenplay',
    'lyrics',
    'novel',
    'creative writing',
    'compose a',
  ];

  static const List<String> _deepReasoningKeywords = [
    'explain in detail',
    'analyze',
    'analysis',
    'compare and contrast',
    'pros and cons',
    'step by step',
    'why does',
    'reasoning',
    'strategy',
    'in depth',
  ];

  static const List<String> _quickFactKeywords = [
    'what is',
    'who is',
    'when is',
    'when was',
    'where is',
    'define',
    'definition of',
    'how many',
    'what time',
    'capital of',
    'convert',
  ];

  /// Returns the concrete provider ([AIProvider.openai] or
  /// [AIProvider.gemini]) that should handle [prompt]. Never returns
  /// [AIProvider.auto].
  static AIProvider decide(String prompt) {
    final normalized = prompt.trim().toLowerCase();
    if (normalized.isEmpty) {
      return AIProvider.openai;
    }

    final wordCount = normalized.split(RegExp(r'\s+')).length;

    if (_containsAny(normalized, _codingKeywords) ||
        _containsAny(normalized, _creativeKeywords) ||
        _containsAny(normalized, _deepReasoningKeywords) ||
        wordCount > _longPromptWordThreshold) {
      return AIProvider.openai;
    }

    if (wordCount <= _shortPromptWordThreshold ||
        _containsAny(normalized, _quickFactKeywords)) {
      return AIProvider.gemini;
    }

    // Default fallback per spec.
    return AIProvider.openai;
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }
}
