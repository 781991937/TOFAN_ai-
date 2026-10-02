import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tofan_ai/data/persistence/supabase_student_learning_repository.dart';
import 'package:tofan_ai/data/persistence/supabase_experience_memory_repository.dart';
import 'package:tofan_ai/data/persistence/supabase_audit_repository.dart';

void main() {
  late SupabaseClient client;

  setUp(() {
    client = SupabaseClient(
      'https://example.supabase.co',
      'test-anon-key',
    );
  });

  test('student repository rejects unauthenticated identity before database access',
      () async {
    final repository = SupabaseStudentLearningRepository(client: client);

    await expectLater(
      repository.load('student-1'),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      repository.clear('student-1'),
      throwsA(isA<StateError>()),
    );
  });

  test('experience repository rejects unauthenticated actor', () async {
    final repository = SupabaseExperienceMemoryRepository(client: client);

    await expectLater(
      repository.load(actorId: 'actor-1'),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      repository.clear(actorId: 'actor-1'),
      throwsA(isA<StateError>()),
    );
  });

  test('audit repository rejects unauthenticated actor', () async {
    final repository = SupabaseAuditRepository(client: client);

    await expectLater(
      repository.load(actorId: 'actor-1'),
      throwsA(isA<StateError>()),
    );
  });
}
