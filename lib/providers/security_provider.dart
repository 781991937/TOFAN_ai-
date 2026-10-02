import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/ai/agent_gateway.dart';
import '../data/auth/supabase_authentication_gateway.dart';
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
    ownerAuthority: SupabaseConfig.ownerActorId.isEmpty
        ? const OwnerAuthority()
        : OwnerAuthority(ownerActorId: SupabaseConfig.ownerActorId),
  );
});
