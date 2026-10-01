enum AuthenticationStatus { authenticated, unauthenticated, expired }

class AuthenticatedIdentity {
  const AuthenticatedIdentity({
    required this.actorId,
    required this.email,
    required this.role,
    required this.authenticatedAt,
    this.sessionId = '',
  });

  final String actorId;
  final String email;
  final String role;
  final DateTime authenticatedAt;
  final String sessionId;

  bool get isOwner => email.toLowerCase() == 'raedtofan86@gmail.com';
}

class AuthenticationSession {
  const AuthenticationSession({
    required this.identity,
    required this.status,
    required this.expiresAt,
  });

  final AuthenticatedIdentity identity;
  final AuthenticationStatus status;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive =>
      status == AuthenticationStatus.authenticated && !isExpired;
}

/// Authentication is deliberately abstract at this layer.
/// A production adapter must validate credentials and establish the identity
/// before an AgentContext is created; email matching alone is not authentication.
abstract interface class AuthenticationGateway {
  Future<AuthenticationSession?> authenticate({
    required String credential,
  });

  Future<void> signOut(String sessionId);
}
