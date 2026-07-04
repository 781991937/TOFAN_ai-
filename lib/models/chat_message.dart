enum MessageRole { user, assistant, system }

extension MessageRoleX on MessageRole {
  String get storageValue => name;

  static MessageRole fromStorageValue(String value) {
    return MessageRole.values.firstWhere(
      (role) => role.storageValue == value,
      orElse: () => MessageRole.user,
    );
  }
}

/// A single chat message stored locally in SQLite.
class ChatMessage {
  final int? id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  ChatMessage copyWith({
    int? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role.storageValue,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      conversationId: map['conversation_id'] as String,
      role: MessageRoleX.fromStorageValue(map['role'] as String),
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
