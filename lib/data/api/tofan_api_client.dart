import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef AccessTokenProvider = Future<String?> Function();

class TofanApiClientException implements Exception {
  const TofanApiClientException(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'TofanApiClientException($statusCode, $code)';
}

/// Flutter-side HTTP adapter. The access token is read from the active
/// Supabase session for every request and is never persisted by this client.
class TofanApiClient {
  TofanApiClient({
    required Uri baseUri,
    required AccessTokenProvider accessTokenProvider,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : baseUri = _validateBaseUri(baseUri),
       _accessTokenProvider = accessTokenProvider,
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  final Uri baseUri;
  final AccessTokenProvider _accessTokenProvider;
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  Future<List<dynamic>> academicFields() async =>
      _asList(await _request('GET', 'v1/academic/fields'), 'fields');

  Future<List<dynamic>> academicSpecializations() async =>
      _asList(await _request('GET', 'v1/academic/specializations'), 'items');

  Future<List<dynamic>> academicConcepts() async =>
      _asList(await _request('GET', 'v1/academic/concepts'), 'items');

  Future<Map<String, dynamic>> academicConcept(String conceptId) async =>
      _asMap(
        await _request('GET', 'v1/academic/concepts/${_segment(conceptId)}'),
        'concept',
      );

  Future<Map<String, dynamic>> academicCourses({
    int limit = 25,
    int offset = 0,
    String? specializationId,
  }) async {
    final query = <String, String>{'limit': '$limit', 'offset': '$offset'};
    if (specializationId != null) query['specialization_id'] = specializationId;
    return _asMap(await _request('GET', 'v1/academic/courses', query: query));
  }

  Future<Map<String, dynamic>> academicCourse(String courseId) async => _asMap(
    await _request('GET', 'v1/academic/courses/${_segment(courseId)}'),
  );

  Future<Map<String, dynamic>> academicLesson(String lessonId) async => _asMap(
    await _request('GET', 'v1/academic/lessons/${_segment(lessonId)}'),
  );

  Future<Map<String, dynamic>> student() async =>
      _asMap(await _request('GET', 'v1/students/me'));

  Future<Map<String, dynamic>> studentProfile() async =>
      _asMap(await _request('GET', 'v1/students/me/profile'));

  Future<Map<String, dynamic>> saveStudentProfile(
    Map<String, dynamic> profile,
  ) async =>
      _asMap(await _request('PUT', 'v1/students/me/profile', body: profile));

  Future<Map<String, dynamic>> learningState() async =>
      _asMap(await _request('GET', 'v1/students/me/learning-state'));

  Future<Map<String, dynamic>> saveLearningState(
    Map<String, dynamic> state,
  ) async => _asMap(
    await _request('PUT', 'v1/students/me/learning-state', body: state),
  );

  Future<Map<String, dynamic>> submitAssessmentAttempt({
    required String assessmentId,
    required Map<String, int> answers,
  }) async => _asMap(
    await _request(
      'POST',
      'v1/learning/assessments/${_segment(assessmentId)}/attempts',
      body: {'answers': answers},
    ),
  );

  Future<List<dynamic>> assessmentAttempts(String assessmentId) async =>
      _asList(
        await _request(
          'GET',
          'v1/learning/assessments/${_segment(assessmentId)}/attempts',
        ),
        'items',
      );

  Future<List<dynamic>> projects() async =>
      _asList(await _request('GET', 'v1/projects'), 'items');

  Future<Map<String, dynamic>> project(String projectId) async =>
      _asMap(await _request('GET', 'v1/projects/${_segment(projectId)}'));

  Future<Map<String, dynamic>> projectProgress(String projectId) async =>
      _asMap(
        await _request('GET', 'v1/projects/${_segment(projectId)}/progress'),
      );

  Future<Map<String, dynamic>> saveProjectProgress({
    required String projectId,
    required Map<String, dynamic> progress,
  }) async => _asMap(
    await _request(
      'PUT',
      'v1/projects/${_segment(projectId)}/progress',
      body: progress,
    ),
  );

  void close() {
    if (_ownsClient) _client.close();
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  }) async {
    final token = (await _accessTokenProvider())?.trim() ?? '';
    if (token.isEmpty) {
      throw const TofanApiClientException(
        401,
        'unauthorized',
        'Sign in to use the TOFAN API.',
      );
    }
    final uri = baseUri
        .resolve(path)
        .replace(queryParameters: query.isEmpty ? null : query);
    try {
      final request = http.Request(method, uri)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          if (body != null) 'Content-Type': 'application/json',
        });
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(
        streamed,
      ).timeout(timeout);
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const TofanApiClientException(
          502,
          'invalid_response',
          'The TOFAN API returned an invalid response.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded['error'];
        if (error is Map) {
          throw TofanApiClientException(
            response.statusCode,
            error['code'] is String
                ? error['code'] as String
                : 'request_failed',
            error['message'] is String
                ? error['message'] as String
                : 'The TOFAN API request failed.',
          );
        }
        throw TofanApiClientException(
          response.statusCode,
          'request_failed',
          'The TOFAN API request failed.',
        );
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const TofanApiClientException(
          502,
          'invalid_response',
          'The TOFAN API returned an invalid data envelope.',
        );
      }
      return data;
    } on TofanApiClientException {
      rethrow;
    } on FormatException {
      throw const TofanApiClientException(
        502,
        'invalid_response',
        'The TOFAN API returned invalid JSON.',
      );
    } on TimeoutException {
      throw const TofanApiClientException(
        504,
        'timeout',
        'The TOFAN API request timed out.',
      );
    } catch (_) {
      throw const TofanApiClientException(
        503,
        'unavailable',
        'The TOFAN API is unavailable.',
      );
    }
  }

  Map<String, dynamic> _asMap(Map<String, dynamic> value, [String? key]) {
    final result = key == null ? value : value[key];
    if (result is! Map) {
      throw const TofanApiClientException(
        502,
        'invalid_response',
        'The TOFAN API returned an unexpected object.',
      );
    }
    return Map<String, dynamic>.from(result);
  }

  List<dynamic> _asList(Map<String, dynamic> value, String key) {
    final result = value[key];
    if (result is! List) {
      throw const TofanApiClientException(
        502,
        'invalid_response',
        'The TOFAN API returned an unexpected list.',
      );
    }
    return result;
  }

  String _segment(String value) => Uri.encodeComponent(value);

  static Uri _validateBaseUri(Uri uri) {
    final loopback = const {
      'localhost',
      '127.0.0.1',
      '::1',
    }.contains(uri.host.toLowerCase());
    if (uri.host.isEmpty ||
        (uri.scheme != 'https' && !(uri.scheme == 'http' && loopback)) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw ArgumentError('The TOFAN API base URL must be an HTTPS origin.');
    }
    return uri.replace(path: uri.path.isEmpty ? '/' : uri.path);
  }
}
