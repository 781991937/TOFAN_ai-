import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../application/ai/agent_state.dart';

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
      final manager = _ref.read(mainManagerAgentProvider);
      final reply = await manager.handle(
        AiAgentRequest(
          role: AiAgentRole.mainManager,
          request: content,
        ),
      );
      final assistantText = reply.text;

      final assistantMessage = ChatMessage(
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: assistantText,
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
