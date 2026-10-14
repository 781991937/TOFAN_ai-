import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tofan_ai/backend/api/academic_catalog_api.dart';
import 'package:tofan_ai/backend/api/api_models.dart';
import 'package:tofan_ai/backend/api/tofan_api_server.dart';
import 'package:tofan_ai/data/academic/academic_catalog.dart';
import 'package:tofan_ai/data/api/tofan_api_client.dart';

const _userId = '00000000-0000-4000-8000-000000000001';
const _otherUserId = '00000000-0000-4000-8000-000000000002';

void main() {
  late _SupabaseHttpStub supabase;
  late TofanApiServer api;
  late HttpServer apiHttpServer;
  late http.Client client;
  late Uri apiBaseUri;
  late TofanApiClient apiClient;

  Future<http.Response> getApi(String path, {String token = 'user-token'}) =>
      client.get(
        apiBaseUri.resolve(path),
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<http.Response> putApi(
    String path,
    Map<String, dynamic> body, {
    String token = 'user-token',
  }) => client.put(
    apiBaseUri.resolve(path),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  Future<http.Response> postApi(
    String path,
    Map<String, dynamic> body, {
    String token = 'user-token',
  }) => client.post(
    apiBaseUri.resolve(path),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  setUp(() async {
    supabase = _SupabaseHttpStub();
    await supabase.start();
    api = TofanApiServer(
      config: SupabaseApiConfig(
        projectUrl: Uri.parse('http://127.0.0.1:${supabase.server!.port}'),
        anonKey: 'test-anon-key',
        serviceRoleKey: 'test-server-only-role',
      ),
      upstreamClient: http.Client(),
    );
    apiHttpServer = await api.start(port: 0);
    apiBaseUri = Uri.parse('http://127.0.0.1:${apiHttpServer.port}');
    client = http.Client();
    apiClient = TofanApiClient(
      baseUri: apiBaseUri,
      accessTokenProvider: () async => 'user-token',
      client: client,
    );
  });

  tearDown(() async {
    client.close();
    await api.close();
    await supabase.close();
  });

  test(
    'health is public; protected endpoints require a verified bearer token',
    () async {
      final health = await client.get(apiBaseUri.resolve('/health'));
      expect(health.statusCode, 200);
      expect(_json(health)['data']['status'], 'ok');

      final protectedResponse = await client.get(
        apiBaseUri.resolve('/v1/academic/fields'),
      );
      expect(protectedResponse.statusCode, 401);
      expect(supabase.authRequests, 0);
    },
  );

  test(
    'academic routes project the canonical catalog and redact answer keys',
    () async {
      final response = await getApi('/v1/academic/courses?limit=5');
      expect(response.statusCode, 200);
      final data = _json(response)['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      expect(data['total'], AcademicCatalogApi().courses.length);
      expect(items, hasLength(5));

      final catalog = AcademicCatalogApi();
      final assessmentRecord = _firstAssessment(catalog);
      final lessonResponse = await getApi(
        '/v1/academic/lessons/${assessmentRecord.lesson.id}',
      );
      expect(lessonResponse.statusCode, 200);
      final lesson =
          _json(lessonResponse)['data']['lesson'] as Map<String, dynamic>;
      final serializedAssessment = (lesson['assessments'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .singleWhere((item) => item['id'] == assessmentRecord.assessment.id);
      final firstQuestion =
          (serializedAssessment['questions'] as List<dynamic>).first
              as Map<String, dynamic>;
      expect(firstQuestion.containsKey('correctIndex'), isFalse);
      expect(firstQuestion['options'], isNotEmpty);

      final fieldsResponse = await getApi('/v1/academic/fields');
      expect(fieldsResponse.statusCode, 200);
      expect(_json(fieldsResponse)['data']['fields'], isNotEmpty);

      final concepts = await apiClient.academicConcepts();
      expect(concepts, isNotEmpty);
      final concept = concepts.first as Map<String, dynamic>;
      final conceptDetail = await apiClient.academicConcept(
        concept['id'] as String,
      );
      expect(conceptDetail['id'], concept['id']);
    },
  );

  test(
    'Flutter API client uses the active session token on protected routes',
    () async {
      final student = await apiClient.student();
      expect(student['studentId'], _userId);
      expect(supabase.authRequests, 1);
    },
  );

  test(
    'student profile and learning state are owner-scoped and reject identity spoofing',
    () async {
      final profile = {
        'name': 'اختبار محلي',
        'university': 'جامعة صنعاء',
        'college': 'كلية الحاسوب وتكنولوجيا المعلومات',
        'specialization': 'الذكاء الاصطناعي',
        'currentYear': 1,
        'currentSemester': 1,
      };
      final savedProfile = await putApi('/v1/students/me/profile', profile);
      expect(savedProfile.statusCode, 200);
      expect(_json(savedProfile)['data']['studentId'], _userId);
      expect(supabase.table('student_profiles').single['student_id'], _userId);

      final otherProfile = await getApi(
        '/v1/students/me/profile',
        token: 'other-token',
      );
      expect(otherProfile.statusCode, 200);
      expect(_json(otherProfile)['data']['profile'], isNull);

      final spoofedProfile = await putApi('/v1/students/me/profile', {
        ...profile,
        'studentId': _otherUserId,
      });
      expect(spoofedProfile.statusCode, 400);

      final conceptId = AcademicCatalog.concepts.first.id;
      final state = {
        'concepts': [
          {'conceptId': conceptId, 'knowledgeLevel': 42.0, 'lastUpdated': 1000},
        ],
        'skills': <Map<String, dynamic>>[],
        'capabilities': <Map<String, dynamic>>[],
        'history': <Map<String, dynamic>>[],
      };
      final savedState = await putApi('/v1/students/me/learning-state', state);
      expect(savedState.statusCode, 200);
      expect(_json(savedState)['data']['studentId'], _userId);
      expect(
        supabase.table('student_learning_state').single['student_id'],
        _userId,
      );

      final otherState = await getApi(
        '/v1/students/me/learning-state',
        token: 'other-token',
      );
      expect(_json(otherState)['data']['state'], isNull);

      final unverifiedCapability = await putApi(
        '/v1/students/me/learning-state',
        {
          ...state,
          'capabilities': [
            {
              'capabilityId': 'capability-test',
              'verified': true,
              'lastUpdated': 1000,
            },
          ],
        },
      );
      expect(unverifiedCapability.statusCode, 400);
    },
  );

  test(
    'assessment attempts are graded against canonical questions and inserted server-side',
    () async {
      final catalog = AcademicCatalogApi();
      final record = _firstAssessment(catalog);
      final answers = {
        for (final question in record.assessment.questions)
          question.id: question.correctIndex,
      };
      final route = '/v1/learning/assessments/${record.assessment.id}/attempts';

      final spoofed = await postApi(route, {
        'answers': answers,
        'student_id': _otherUserId,
      });
      expect(spoofed.statusCode, 400);

      final submitted = await postApi(route, {'answers': answers});
      expect(submitted.statusCode, 201);
      final result = _json(submitted)['data'] as Map<String, dynamic>;
      expect(result['attemptNumber'], 1);
      expect(result['score'], record.assessment.questions.length);
      expect(result['total'], record.assessment.questions.length);
      expect(result['passed'], isTrue);
      expect(result['wrongQuestionIds'], isEmpty);
      expect(supabase.lastAssessmentInsertApiKey, 'test-server-only-role');
      expect(
        supabase.table('assessment_attempts').single['student_id'],
        _userId,
      );

      final history = await getApi(route);
      expect(history.statusCode, 200);
      expect((_json(history)['data']['items'] as List), hasLength(1));

      final duplicatePass = await postApi(route, {'answers': answers});
      expect(duplicatePass.statusCode, 409);
      expect(supabase.table('assessment_attempts'), hasLength(1));
    },
  );

  test(
    'project progress accepts only canonical tasks and remains owner-scoped',
    () async {
      final catalog = AcademicCatalogApi();
      final projectRecord = catalog.projects.firstWhere(
        (record) => record.project.implementationTasks.isNotEmpty,
      );
      final project = projectRecord.project;
      final route = '/v1/projects/${project.id}/progress';
      final body = {
        'status': 'in_progress',
        'completedTasks': [project.implementationTasks.first],
        'notes': 'اختبار تكامل محلي',
      };

      final saved = await putApi(route, body);
      expect(saved.statusCode, 200);
      expect(_json(saved)['data']['projectId'], project.id);
      expect(
        supabase.table('student_project_progress').single['student_id'],
        _userId,
      );

      final otherProgress = await getApi(route, token: 'other-token');
      expect(_json(otherProgress)['data']['progress'], isNull);

      final invalidTask = await putApi(route, {
        ...body,
        'completedTasks': ['ليست مهمة في المشروع الكانوني'],
      });
      expect(invalidTask.statusCode, 400);
    },
  );
}

Map<String, dynamic> _json(http.Response response) =>
    jsonDecode(response.body) as Map<String, dynamic>;

AcademicAssessmentRecord _firstAssessment(AcademicCatalogApi catalog) {
  for (final course in catalog.courses) {
    for (final unit in course.course.normalizedUnits) {
      for (final lesson in unit.lessons) {
        for (final assessment in lesson.assessments) {
          if (assessment.questions.isNotEmpty) {
            return AcademicAssessmentRecord(
              assessment: assessment,
              course: course,
              lesson: lesson,
            );
          }
        }
      }
    }
  }
  throw StateError('The canonical catalog contains no assessment questions.');
}

class _SupabaseHttpStub {
  static const _anonKey = 'test-anon-key';
  static const _serviceRoleKey = 'test-server-only-role';

  final Map<String, List<Map<String, dynamic>>> _tables = {};
  final Map<String, String> _tokenUsers = const {
    'user-token': _userId,
    'other-token': _otherUserId,
  };
  final Map<String, String> _lastApiKeyByTable = {};
  HttpServer? server;
  int authRequests = 0;

  String? get lastAssessmentInsertApiKey =>
      _lastApiKeyByTable['assessment_attempts'];

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server!.listen((request) => _handle(request));
  }

  Future<void> close() async {
    await server?.close(force: true);
  }

  List<Map<String, dynamic>> table(String name) =>
      _tables.putIfAbsent(name, () => <Map<String, dynamic>>[]);

  Future<void> _handle(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    final token = _bearer(request);
    final apiKey = request.headers.value('apikey');
    final isServiceRole =
        apiKey == _serviceRoleKey &&
        request.headers.value(HttpHeaders.authorizationHeader) ==
            'Bearer $_serviceRoleKey';

    if (segments.length == 3 &&
        segments[0] == 'auth' &&
        segments[1] == 'v1' &&
        segments[2] == 'user') {
      authRequests++;
      final userId = _tokenUsers[token];
      if (apiKey != _anonKey || userId == null) {
        await _reply(request, 401, {'message': 'invalid token'});
      } else {
        await _reply(request, 200, {
          'id': userId,
          'email': userId == _userId
              ? 'student@example.test'
              : 'other@example.test',
          'app_metadata': {'role': 'student'},
        });
      }
      return;
    }

    if (segments.length != 3 || segments[0] != 'rest' || segments[1] != 'v1') {
      await _reply(request, 404, {'message': 'not found'});
      return;
    }
    final tableName = segments[2];
    _lastApiKeyByTable[tableName] = apiKey ?? '';
    final userId = _tokenUsers[token];
    if (!isServiceRole && (apiKey != _anonKey || userId == null)) {
      await _reply(request, 401, {'message': 'unauthorized'});
      return;
    }
    if (tableName == 'assessment_attempts' &&
        request.method == 'POST' &&
        !isServiceRole) {
      await _reply(request, 403, {'message': 'server grading only'});
      return;
    }

    final rows = table(tableName);
    if (request.method == 'GET') {
      var matching = rows
          .where((row) {
            if (!isServiceRole && row['student_id'] != userId) return false;
            for (final key in const [
              'student_id',
              'assessment_id',
              'project_id',
            ]) {
              final filter = request.uri.queryParameters[key];
              if (filter != null &&
                  filter.startsWith('eq.') &&
                  row[key] != filter.substring(3)) {
                return false;
              }
            }
            return true;
          })
          .toList(growable: true);
      if (request.uri.queryParameters['order'] case final String order
          when order.contains('attempt_number')) {
        matching.sort(
          (a, b) => ((b['attempt_number'] as num?) ?? 0).compareTo(
            (a['attempt_number'] as num?) ?? 0,
          ),
        );
      }
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '');
      if (limit != null) matching = matching.take(limit).toList();
      await _reply(request, 200, matching);
      return;
    }

    if (request.method == 'POST') {
      final decoded = jsonDecode(await utf8.decoder.bind(request).join());
      if (decoded is! Map) {
        await _reply(request, 400, {'message': 'object required'});
        return;
      }
      final row = Map<String, dynamic>.from(decoded);
      if (tableName == 'assessment_attempts') {
        if (row.containsKey('percentage') || row.containsKey('passed')) {
          await _reply(request, 400, {
            'message': 'generated columns are read-only',
          });
          return;
        }
        final score = (row['score'] as num).toInt();
        final total = (row['total'] as num).toInt();
        row['percentage'] = (score * 100 / total).roundToDouble() / 1;
        row['passed'] = score * 100 >= total * 60;
      } else if (!isServiceRole && row['student_id'] != userId) {
        await _reply(request, 403, {'message': 'owner mismatch'});
        return;
      }

      final conflict = request.uri.queryParameters['on_conflict'];
      if (conflict != null) {
        final keys = conflict.split(',');
        final existingIndex = rows.indexWhere(
          (candidate) => keys.every((key) => candidate[key] == row[key]),
        );
        if (existingIndex >= 0) {
          rows[existingIndex] = row;
        } else {
          rows.add(row);
        }
      } else {
        rows.add(row);
      }
      await _reply(request, 201, [row]);
      return;
    }

    if (request.method == 'DELETE') {
      if (isServiceRole) {
        rows.clear();
      } else {
        rows.removeWhere((row) {
          if (row['student_id'] != userId) return false;
          final filter = request.uri.queryParameters['student_id'];
          return filter == null || filter == 'eq.$userId';
        });
      }
      await _reply(request, 204, null);
      return;
    }

    await _reply(request, 405, {'message': 'method not allowed'});
  }

  String? _bearer(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader) ?? '';
    return header.startsWith('Bearer ') ? header.substring(7) : null;
  }

  Future<void> _reply(HttpRequest request, int status, Object? body) async {
    request.response.statusCode = status;
    if (status != 204) {
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(body));
    }
    await request.response.close();
  }
}
