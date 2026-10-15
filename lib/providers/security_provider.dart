import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/ai/agent_gateway.dart';
import '../data/auth/supabase_authentication_gateway.dart';
import '../data/persistence/supabase_student_learning_repository.dart';
import '../data/persistence/supabase_experience_memory_repository.dart';
import '../data/persistence/supabase_audit_repository.dart';
import '../domain/learning/student_learning_repository.dart';
import '../abqari/experience_memory_repository.dart';
import '../domain/security/audit_repository.dart';
import '../domain/security/authentication_models.dart';
import '../domain/security/owner_authority.dart';
import '../config/supabase_config.dart';

final authenticationGatewayProvider = Provider<AuthenticationGateway>((ref) {
  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase Auth is not configured. Provide SUPABASE_URL and '
      'SUPABASE_ANON_KEY at build time.',
    );
  }
  return SupabaseAuthenticationGateway();
});

final agentGatewayProvider = Provider<AgentGateway>((ref) {
  return AgentGateway(
    // Fail closed: a client build-time value is not trusted proof of owner
    // authority. Re-enable owner-only operations only after a server-backed
    // owner authorization flow is implemented and verified.
    ownerAuthority: const OwnerAuthority(),
    auditRepository: ref.read(auditRepositoryProvider),
  );
});

final studentLearningRepositoryProvider = Provider<StudentLearningRepository>((ref) {
  return SupabaseStudentLearningRepository();
});

final experienceMemoryRepositoryProvider =
    Provider<ExperienceMemoryRepository>((ref) {
  return SupabaseExperienceMemoryRepository();
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return SupabaseAuditRepository();
});
