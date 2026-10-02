import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/security/authentication_models.dart';

/// Supabase Auth adapter. Identity is taken from the verified Supabase session
/// and its immutable user id; email is profile data only.
class SupabaseAuthenticationGateway implements AuthenticationGateway {
  SupabaseAuthenticationGateway({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<AuthenticationSession?> authenticate({
    required String credential,
  }) async {
    final separator = credential.indexOf('\n');
    if (separator <= 0) {
      throw ArgumentError(
        'Credential must contain email and password separated by a newline.',
      );
    }

    final email = credential.substring(0, separator).trim();
    final password = credential.substring(separator + 1);
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password are required.');
    }

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = response.session;
    final user = response.user;
    if (session == null || user == null) {
      return null;
    }

    final identity = AuthenticatedIdentity(
      actorId: user.id,
      email: user.email ?? '',
      role: 'student',
      authenticatedAt: DateTime.now(),
      sessionId: session.accessToken,
    );

    return AuthenticationSession(
      identity: identity,
      status: AuthenticationStatus.authenticated,
      expiresAt: session.expiresAt == null
          ? DateTime.now().add(const Duration(hours: 1))
          : DateTime.fromMillisecondsSinceEpoch(
              session.expiresAt! * 1000,
            ),
    );
  }

  @override
  Future<void> signOut(String sessionId) async {
    await _client.auth.signOut();
  }
}
