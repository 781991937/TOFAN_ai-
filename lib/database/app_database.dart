import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../domain/security/audit_models.dart';
import '../abqari/experience_memory.dart';
import '../utils/constants.dart';

/// Local persistence adapter for client-owned data.
/// Production server persistence remains a separate roadmap requirement.
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
      onUpgrade: _onUpgrade,
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

    await _createAuditTable(db);
    await _createStudentLearningTable(db);
    await _createExperienceMemoryTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createAuditTable(db);
    }
    if (oldVersion < 3) {
      await _createStudentLearningTable(db);
    }
    if (oldVersion < 4) {
      await _createExperienceMemoryTable(db);
    }
  }

  Future<void> _createStudentLearningTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppConstants.studentLearningTable} (
        student_id TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createExperienceMemoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppConstants.experienceMemoryTable} (
        id TEXT PRIMARY KEY,
        actor_id TEXT NOT NULL,
        task TEXT NOT NULL,
        outcome TEXT NOT NULL,
        observation TEXT NOT NULL,
        learned_skill_ids TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS ${AppConstants.experienceActorIndex}
      ON ${AppConstants.experienceMemoryTable} (actor_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS ${AppConstants.experienceCreatedIndex}
      ON ${AppConstants.experienceMemoryTable} (created_at)
    ''');
  }

  Future<void> _createAuditTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppConstants.auditEventsTable} (
        id TEXT PRIMARY KEY,
        actor_id TEXT NOT NULL,
        action TEXT NOT NULL,
        resource_id TEXT NOT NULL,
        outcome TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        reason TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS ${AppConstants.auditActorIndex}
      ON ${AppConstants.auditEventsTable} (actor_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS ${AppConstants.auditResourceIndex}
      ON ${AppConstants.auditEventsTable} (resource_id)
    ''');
  }

  Future<void> recordAuditEvent(AuditEvent event) async {
    final db = await database;
    await db.insert(
      AppConstants.auditEventsTable,
      {
        'id': event.id,
        'actor_id': event.actorId,
        'action': event.action,
        'resource_id': event.resourceId,
        'outcome': event.outcome.name,
        'timestamp': event.timestamp.millisecondsSinceEpoch,
        'reason': event.reason,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AuditEvent>> getAuditEvents({
    String? actorId,
    String? resourceId,
  }) async {
    final db = await database;
    final clauses = <String>[];
    final args = <Object?>[];

    if (actorId != null) {
      clauses.add('actor_id = ?');
      args.add(actorId);
    }
    if (resourceId != null) {
      clauses.add('resource_id = ?');
      args.add(resourceId);
    }

    final rows = await db.query(
      AppConstants.auditEventsTable,
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'timestamp DESC',
    );

    return rows.map((row) => AuditEvent(
      id: row['id'] as String,
      actorId: row['actor_id'] as String,
      action: row['action'] as String,
      resourceId: row['resource_id'] as String,
      outcome: AuditOutcome.values.firstWhere(
        (value) => value.name == row['outcome'],
        orElse: () => AuditOutcome.failure,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      reason: row['reason'] as String,
    )).toList(growable: false);
  }

  Future<void> saveStudentLearningState(
    String studentId,
    String payload,
  ) async {
    final db = await database;
    await db.insert(
      AppConstants.studentLearningTable,
      {
        'student_id': studentId,
        'payload': payload,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> loadStudentLearningState(String studentId) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.studentLearningTable,
      columns: ['payload'],
      where: 'student_id = ?',
      whereArgs: [studentId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['payload'] as String;
  }

  Future<void> clearStudentLearningState(String studentId) async {
    final db = await database;
    await db.delete(
      AppConstants.studentLearningTable,
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }

  Future<void> saveExperience(AbqariExperience experience) async {
    final db = await database;
    await db.insert(
      AppConstants.experienceMemoryTable,
      {
        'id': experience.id,
        'actor_id': experience.actorId,
        'task': experience.task,
        'outcome': experience.outcome.name,
        'observation': experience.observation,
        'learned_skill_ids': experience.learnedSkillIds.join('|'),
        'created_at': experience.createdAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AbqariExperience>> getExperiences({
    String? actorId,
    String? skillId,
  }) async {
    final db = await database;
    final clauses = <String>[];
    final args = <Object?>[];
    if (actorId != null) {
      clauses.add('actor_id = ?');
      args.add(actorId);
    }
    final rows = await db.query(
      AppConstants.experienceMemoryTable,
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
    );
    final experiences = rows.map((row) {
      final outcomeName = row['outcome'] as String;
      final outcome = ExperienceOutcome.values.firstWhere(
        (value) => value.name == outcomeName,
        orElse: () => ExperienceOutcome.failure,
      );
      return AbqariExperience(
        id: row['id'] as String,
        actorId: row['actor_id'] as String,
        task: row['task'] as String,
        outcome: outcome,
        observation: row['observation'] as String,
        learnedSkillIds: (row['learned_skill_ids'] as String)
            .split('|')
            .where((id) => id.isNotEmpty)
            .toList(growable: false),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
    }).where((experience) {
      return skillId == null || experience.learnedSkillIds.contains(skillId);
    }).toList(growable: false);
    return experiences;
  }

  Future<void> clearExperiences({String? actorId}) async {
    final db = await database;
    await db.delete(
      AppConstants.experienceMemoryTable,
      where: actorId == null ? null : 'actor_id = ?',
      whereArgs: actorId == null ? null : [actorId],
    );
  }

  Future<void> upsertConversation(Conversation conversation) async {
    final db = await database;
    await db.insert(AppConstants.conversationsTable, conversation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Conversation>> getConversations() async {
    final db = await database;
    final rows = await db.query(AppConstants.conversationsTable,
        orderBy: 'updated_at DESC');
    return rows.map(Conversation.fromMap).toList();
  }

  Future<void> deleteConversation(String id) async {
    final db = await database;
    await db.delete(AppConstants.chatMessagesTable,
        where: 'conversation_id = ?', whereArgs: [id]);
    await db.delete(AppConstants.conversationsTable,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertMessage(ChatMessage message) async {
    final db = await database;
    return db.insert(AppConstants.chatMessagesTable, message.toMap()..remove('id'));
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final db = await database;
    final rows = await db.query(AppConstants.chatMessagesTable,
        where: 'conversation_id = ?', whereArgs: [conversationId],
        orderBy: 'created_at ASC');
    return rows.map(ChatMessage.fromMap).toList();
  }

  Future<void> clearMessages(String conversationId) async {
    final db = await database;
    await db.delete(AppConstants.chatMessagesTable,
        where: 'conversation_id = ?', whereArgs: [conversationId]);
  }
}
