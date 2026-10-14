import 'dart:io';

class SupabaseApiConfig {
  const SupabaseApiConfig({
    required this.projectUrl,
    required this.anonKey,
    required this.serviceRoleKey,
    this.requestTimeout = const Duration(seconds: 10),
  });

  final Uri projectUrl;
  final String anonKey;
  final String serviceRoleKey;
  final Duration requestTimeout;

  factory SupabaseApiConfig.fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final values = environment ?? Platform.environment;
    final url = values['SUPABASE_URL']?.trim() ?? '';
    final anonKey = values['SUPABASE_ANON_KEY']?.trim() ?? '';
    final serviceRoleKey = values['SUPABASE_SERVICE_ROLE_KEY']?.trim() ?? '';

    if (url.isEmpty || anonKey.isEmpty || serviceRoleKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL, SUPABASE_ANON_KEY and the server-only '
        'SUPABASE_SERVICE_ROLE_KEY must be configured.',
      );
    }

    return SupabaseApiConfig(
      projectUrl: Uri.parse(url),
      anonKey: anonKey,
      serviceRoleKey: serviceRoleKey,
    ).validated();
  }

  SupabaseApiConfig validated() {
    final loopback = const {
      'localhost',
      '127.0.0.1',
      '::1',
    }.contains(projectUrl.host.toLowerCase());
    if ((projectUrl.scheme != 'https' &&
            !(projectUrl.scheme == 'http' && loopback)) ||
        projectUrl.host.isEmpty ||
        (projectUrl.path.isNotEmpty && projectUrl.path != '/') ||
        projectUrl.userInfo.isNotEmpty ||
        projectUrl.hasQuery ||
        projectUrl.hasFragment ||
        anonKey.trim().isEmpty ||
        serviceRoleKey.trim().isEmpty ||
        requestTimeout <= Duration.zero) {
      throw ArgumentError('Invalid or unsafe Supabase API configuration.');
    }
    return this;
  }
}

class ApiPrincipal {
  const ApiPrincipal({required this.userId, this.email});

  /// The verified Supabase Auth user id; never supplied by an API request body.
  final String userId;
  final String? email;
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'ApiException($statusCode, $code)';
}
