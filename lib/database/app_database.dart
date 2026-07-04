import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../utils/constants.dart';

/// Wraps a local SQLite database used for persisting conversations
/// and chat messages on-device.
class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.conversationsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.chatMessagesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (conversation_id)
          REFERENCES ${AppConstants.conversationsTable} (id)
          ON DELETE CASCADE
      )
    ''');
  }

  // Conversation operations

  Future<void> upsertConversation(Conversation conversation) async {
    final db = await database;
    await db.insert(
      AppConstants.conversationsTable,
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Conversation>> getConversations() async {
    final db = await database;
    final rows = await db.query(
      AppConstants.conversationsTable,
      orderBy: 'updated_at DESC',
    );
    return rows.map(Conversation.fromMap).toList();
  }

  Future<void> deleteConversation(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.chatMessagesTable,
      where: 'conversation_id = ?',
      whereArgs: [id],
    );
    await db.delete(
      AppConstants.conversationsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message operations

  Future<int> insertMessage(ChatMessage message) async {
    final db = await database;
    return db.insert(
      AppConstants.chatMessagesTable,
      message.toMap()..remove('id'),
    );
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.chatMessagesTable,
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    return rows.map(ChatMessage.fromMap).toList();
  }

  Future<void> clearMessages(String conversationId) async {
    final db = await database;
    await db.delete(
      AppConstants.chatMessagesTable,
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }
}
