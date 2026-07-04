import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/ai/ai_manager.dart';
import '../services/ai/ai_models.dart';
import '../services/ai/ai_provider.dart';
import '../services/gemini_service.dart';
import '../services/openai_service.dart';

// Kept for image generation (see ImagesScreen), which still talks to the
// OpenAI Images API directly rather than through the AIManager.
final openAiServiceProvider = Provider<OpenAiService>((ref) => OpenAiService());
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

/// Holds the id of the conversation currently open in the chat screen.
final activeConversationIdProvider = StateProvider<String>((ref) {
  return const Uuid().v4();
});

/// Loads all messages for the active conversation from SQLite.
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>>(
        (ref) {
  return ChatMessagesNotifier(ref);
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref _ref;

  Future<void> _init() async {
    await loadMessages();
  }

  Future<void> loadMessages() async {
    final db = _ref.read(appDatabaseProvider);
    final conversationId = _ref.read(activeConversationIdProvider);
    state = const AsyncValue.loading();
    try {
      final messages = await db.getMessages(conversationId);
      state = AsyncValue.data(messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendMessage(String content) async {
    final db = _ref.read(appDatabaseProvider);
    final conversationId = _ref.read(activeConversationIdProvider);
    final aiManager = _ref.read(aiManagerProvider);
    final manualOverride = _ref.read(aiManualOverrideProvider);

    final now = DateTime.now();
    await db.upsertConversation(Conversation(
      id: conversationId,
      title: content.length > 40 ? content.substring(0, 40) : content,
      createdAt: now,
      updatedAt: now,
    ));

    final userMessage = ChatMessage(
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: now,
    );
    await db.insertMessage(userMessage);
    await loadMessages();

    try {
      final history = await db.getMessages(conversationId);
      // Exclude the message we just inserted; AIManager appends the
      // current prompt itself.
      final priorMessages = history.length > 1
          ? history.sublist(0, history.length - 1)
          : <ChatMessage>[];
      final formattedHistory = priorMessages
          .map((m) => AIChatMessage(
                role: m.role == MessageRole.user ? 'user' : 'assistant',
                content: m.content,
              ))
          .toList();

      final reply = await aiManager.sendPrompt(
        content,
        history: formattedHistory,
        override: manualOverride ?? AIProvider.auto,
      );

      final assistantMessage = ChatMessage(
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );
      await db.insertMessage(assistantMessage);
      await loadMessages();
    } catch (error) {
      final errorMessage = ChatMessage(
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: 'Error: ${error.toString()}',
        createdAt: DateTime.now(),
      );
      await db.insertMessage(errorMessage);
      await loadMessages();
    }
  }

  Future<void> clearConversation() async {
    final db = _ref.read(appDatabaseProvider);
    final conversationId = _ref.read(activeConversationIdProvider);
    await db.clearMessages(conversationId);
    await loadMessages();
  }
}
