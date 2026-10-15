import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_models.dart';

/// Supabase Auth/PostgREST adapter for the TOFAN HTTP API.
/// User-owned reads and writes always use the caller's verified JWT, so the
/// existing auth.uid()::text RLS policies remain the data boundary.
class SupabaseRestGateway {
  SupabaseRestGateway({required SupabaseApiConfig config, http.Client? client})
    : _config = config.validated(),
      _client = client ?? http.Client();

  final SupabaseApiConfig _config;
  final http.Client _client;

  static const _tables = <String>{
    'student_profiles',
    'student_learning_state',
    'student_learning_plans',
    'student_project_assignments',
    'project_task_evidence',
    'student_capability_verifications',
    'assessment_attempts',
    'student_project_progress',
  };

  Future<ApiPrincipal> authenticate(String accessToken) async {
    final token = accessToken.trim();
    if (token.isEmpty || token.length > 8192) {
      throw const ApiException(
        401,
        'unauthorized',
        'A valid bearer token is required.',
      );
    }

    final response = await _send(
      'GET',
      _config.projectUrl.resolve('auth/v1/user'),
      headers: {
        'apikey': _config.anonKey,
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ApiException(
        401,
        'unauthorized',
        'The Supabase session is invalid.',
      );
    }
    _requireSuccess(response);

    final decoded = _decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        502,
        'invalid_auth_response',
        'Supabase Auth returned an invalid response.',
      );
    }
    final userId = decoded['id'];
    if (userId is! String || !_isUuid(userId)) {
      throw const ApiException(
        502,
        'invalid_auth_response',
        'Supabase Auth returned an invalid identity.',
      );
    }
    return ApiPrincipal(
      userId: userId,
      email: decoded['email'] is String ? decoded['email'] as String : null,
      role:
          decoded['app_metadata'] is Map &&
              (decoded['app_metadata'] as Map)['role'] is String
          ? (decoded['app_metadata'] as Map)['role'] as String
          : 'student',
    );
  }

  Future<List<Map<String, dynamic>>> selectRows({
    required String table,
    required String accessToken,
    required Map<String, String> query,
  }) async {
    _requireTable(table);
    final response = await _send(
      'GET',
      _tableUri(table, query),
      headers: _userHeaders(accessToken),
    );
    _requireSuccess(response);
    final decoded = _decode(response.body);
    if (decoded is! List) {
      throw const ApiException(
        502,
        'invalid_data_response',
        'Supabase returned an invalid data response.',
      );
    }
    return decoded
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> upsertUserRow({
    required String table,
    required String accessToken,
    required Map<String, dynamic> row,
    required String onConflict,
  }) async {
    _requireTable(table);
    if (table == 'assessment_attempts') {
      throw ArgumentError(
        'Assessment attempts can only be inserted by the trusted grader.',
      );
    }
    final response = await _send(
      'POST',
      _tableUri(table, {'on_conflict': onConflict}),
      headers: {
        ..._userHeaders(accessToken),
        'Prefer': 'resolution=merge-duplicates,return=representation',
      },
      body: row,
    );
    _requireSuccess(response);
    return _firstRow(response.body);
  }

  Future<List<Map<String, dynamic>>> selectRowsAsServer({
    required String table,
    required Map<String, String> query,
  }) async {
    _requireTable(table);
    final response = await _send(
      'GET',
      _tableUri(table, query),
      headers: {
        'apikey': _config.serviceRoleKey,
        'Authorization': 'Bearer ${_config.serviceRoleKey}',
        'Accept': 'application/json',
      },
    );
    _requireSuccess(response);
    final decoded = _decode(response.body);
    if (decoded is! List) {
      throw const ApiException(
        502,
        'invalid_data_response',
        'Supabase returned an invalid data response.',
      );
    }
    return decoded
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  Future<void> deleteUserRows({
    required String table,
    required String accessToken,
    required Map<String, String> query,
  }) async {
    _requireTable(table);
    if (table == 'assessment_attempts') {
      throw ArgumentError('Assessment attempts are append-only.');
    }
    final response = await _send(
      'DELETE',
      _tableUri(table, query),
      headers: {..._userHeaders(accessToken), 'Prefer': 'return=minimal'},
    );
    _requireSuccess(response);
  }

  /// The only service-role operation exposed by this adapter. The caller must
  /// supply student_id from [ApiPrincipal.userId], never from request input.
  Future<Map<String, dynamic>?> insertGradedAssessmentAttempt(
    Map<String, dynamic> row,
  ) async {
    final response = await _send(
      'POST',
      _tableUri('assessment_attempts', const {}),
      headers: {
        'apikey': _config.serviceRoleKey,
        'Authorization': 'Bearer ${_config.serviceRoleKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer': 'return=representation',
      },
      body: row,
    );
    _requireSuccess(response);
    return _firstRow(response.body);
  }

  /// Persists a plan derived by the trusted server-side assessment pipeline.
  Future<Map<String, dynamic>?> upsertDerivedLearningPlan(
    Map<String, dynamic> row,
  ) async {
    final response = await _send(
      'POST',
      _tableUri('student_learning_plans', {'on_conflict': 'student_id'}),
      headers: {
        'apikey': _config.serviceRoleKey,
        'Authorization': 'Bearer ${_config.serviceRoleKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer': 'resolution=merge-duplicates,return=representation',
      },
      body: row,
    );
    _requireSuccess(response);
    return _firstRow(response.body);
  }

  Future<Map<String, dynamic>?> upsertDerivedProjectAssignment(
    Map<String, dynamic> row,
  ) async {
    final response = await _send(
      'POST',
      _tableUri('student_project_assignments', {'on_conflict': 'student_id'}),
      headers: {
        'apikey': _config.serviceRoleKey,
        'Authorization': 'Bearer ${_config.serviceRoleKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer': 'resolution=merge-duplicates,return=representation',
      },
      body: row,
    );
    _requireSuccess(response);
    return _firstRow(response.body);
  }

  /// Evidence quality fields are server-owned; clients may read evidence but
  /// can never insert an accepted/reviewed row directly through PostgREST.
  Future<Map<String, dynamic>?> insertProjectTaskEvidence(
    Map<String, dynamic> row,
  ) async {
    final response = await _send(
      'POST',
      _tableUri('project_task_evidence', const {}),
      headers: {
        'apikey': _config.serviceRoleKey,
        'Authorization': 'Bearer ${_config.serviceRoleKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer': 'return=representation',
      },
      body: row,
    );
    _requireSuccess(response);
    return _firstRow(response.body);
  }

  Future<Map<String, dynamic>?> upsertCapabilityVerification(
    Map<String, dynamic> row,
  ) async {
    final response = await _send(
      'POST',
      _tableUri('student_capability_verifications', {
        'on_conflict': 'student_id',
      }),
      headers: {
        'apikey': _config.serviceRoleKey,
        'Authorization': 'Bearer ${_config.serviceRoleKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer': 'resolution=merge-duplicates,return=representation',
      },
      body: row,
    );
    _requireSuccess(response);
    return _firstRow(response.body);
  }

  Future<Map<String, dynamic>?> updateProjectTaskEvidenceReview({
    required String evidenceId,
    required Map<String, dynamic> values,
  }) async {
    final response = await _send(
      'PATCH',
      _tableUri('project_task_evidence', {'evidence_id': 'eq.$evidenceId'}),
      headers: {
        'apikey': _config.serviceRoleKey,
        'Authorization': 'Bearer ${_config.serviceRoleKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer': 'return=representation',
      },
      body: values,
    );
    _requireSuccess(response);
    return _firstRow(response.body);
  }

  void close() => _client.close();

  Map<String, String> _userHeaders(String accessToken) => {
    'apikey': _config.anonKey,
    'Authorization': 'Bearer ${accessToken.trim()}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _tableUri(String table, Map<String, String> query) {
    _requireTable(table);
    return _config.projectUrl
        .resolve('rest/v1/$table')
        .replace(queryParameters: query.isEmpty ? null : query);
  }

  void _requireTable(String table) {
    if (!_tables.contains(table)) {
      throw ArgumentError.value(table, 'table', 'Not an API-managed table.');
    }
  }

  Future<http.Response> _send(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Object? body,
  }) async {
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client
          .send(request)
          .timeout(_config.requestTimeout);
      return await http.Response.fromStream(
        streamed,
      ).timeout(_config.requestTimeout);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        502,
        'supabase_unavailable',
        'The Supabase service is unavailable.',
      );
    }
  }

  void _requireSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    switch (response.statusCode) {
      case 401:
        throw const ApiException(
          401,
          'unauthorized',
          'The Supabase session is invalid.',
        );
      case 403:
        throw const ApiException(
          403,
          'forbidden',
          'The requested data is not permitted.',
        );
      case 404:
        throw const ApiException(
          404,
          'not_found',
          'The requested record was not found.',
        );
      case 409:
        throw const ApiException(
          409,
          'conflict',
          'The request conflicts with an existing record.',
        );
      case 400:
        throw const ApiException(
          400,
          'invalid_data',
          'Supabase rejected the data.',
        );
      default:
        throw const ApiException(
          502,
          'supabase_error',
          'The Supabase service could not complete the request.',
        );
    }
  }

  dynamic _decode(String source) {
    try {
      return jsonDecode(source);
    } on FormatException {
      throw const ApiException(
        502,
        'invalid_data_response',
        'Supabase returned invalid JSON.',
      );
    }
  }

  Map<String, dynamic>? _firstRow(String source) {
    if (source.trim().isEmpty) return null;
    final decoded = _decode(source);
    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  bool _isUuid(String value) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);
}
