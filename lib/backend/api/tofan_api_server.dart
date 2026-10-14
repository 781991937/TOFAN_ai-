import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'academic_catalog_api.dart';
import 'api_models.dart';
import 'supabase_rest_gateway.dart';
import '../../domain/academic/academic_models.dart';
import '../../domain/learning/learning_models.dart';
import '../../application/learning/assessment_analysis_engine.dart';
import '../../application/learning/learning_intelligence.dart';

class TofanApiServer {
  TofanApiServer({
    required SupabaseApiConfig config,
    http.Client? upstreamClient,
    Set<String> allowedOrigins = const {},
  }) : _gateway = SupabaseRestGateway(config: config, client: upstreamClient),
       _allowedOrigins = Set.unmodifiable(allowedOrigins);

  final SupabaseRestGateway _gateway;
  final Set<String> _allowedOrigins;
  final AcademicCatalogApi _catalog = AcademicCatalogApi();
  final Uuid _uuid = const Uuid();
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;

  Future<HttpServer> start({
    InternetAddress? bindAddress,
    int port = 8080,
  }) async {
    if (_server != null) throw StateError('The API server is already running.');
    final server = await HttpServer.bind(
      bindAddress ?? InternetAddress.loopbackIPv4,
      port,
    );
    _server = server;
    _subscription = server.listen(
      (request) => unawaited(_handle(request)),
      onError: (Object _, StackTrace __) {},
    );
    return server;
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _server?.close(force: true);
    _server = null;
    _subscription = null;
    _gateway.close();
  }

  Future<void> _handle(HttpRequest request) async {
    final origin = request.headers.value('Origin');
    if (origin != null && !_allowedOrigins.contains(origin)) {
      await _write(
        request,
        403,
        _error('origin_not_allowed', 'This origin is not allowed.'),
      );
      return;
    }

    if (request.method == 'OPTIONS') {
      await _write(request, 204, const {}, preflight: true);
      return;
    }

    try {
      if (request.method == 'GET' && request.uri.path == '/health') {
        await _write(request, 200, const {
          'data': {'status': 'ok', 'service': 'tofan-api', 'version': 1},
        });
        return;
      }

      final token = _extractBearer(request);
      final principal = await _gateway.authenticate(token);
      final result = await _dispatch(request, principal, token);
      await _write(request, result.$1, result.$2);
    } on ApiException catch (error) {
      await _write(
        request,
        error.statusCode,
        _error(error.code, error.message),
      );
    } on FormatException {
      await _write(
        request,
        400,
        _error('invalid_json', 'The request body is not valid JSON.'),
      );
    } catch (_) {
      await _write(
        request,
        500,
        _error('internal_error', 'The server could not complete the request.'),
      );
    }
  }

  Future<(int, Map<String, dynamic>)> _dispatch(
    HttpRequest request,
    ApiPrincipal principal,
    String accessToken,
  ) async {
    final segments = request.uri.pathSegments;
    final method = request.method;

    if (_isPath(segments, ['v1', 'academic', 'fields']) && method == 'GET') {
      return (
        200,
        {
          'data': {'fields': _catalog.fields()},
        },
      );
    }
    if (_isPath(segments, ['v1', 'academic', 'specializations']) &&
        method == 'GET') {
      return (
        200,
        {
          'data': {'items': _catalog.specializations()},
        },
      );
    }
    if (_isPath(segments, ['v1', 'academic', 'concepts']) && method == 'GET') {
      final items = _catalog.concepts();
      return (
        200,
        {
          'data': {'items': items, 'total': items.length},
        },
      );
    }
    if (segments.length == 4 &&
        segments[0] == 'v1' &&
        segments[1] == 'academic' &&
        segments[2] == 'concepts' &&
        method == 'GET') {
      final concept = _catalog.conceptById(segments[3]);
      if (concept == null) {
        throw const ApiException(
          404,
          'concept_not_found',
          'The concept was not found.',
        );
      }
      return (
        200,
        {
          'data': {'concept': concept},
        },
      );
    }
    if (_isPath(segments, ['v1', 'academic', 'courses']) && method == 'GET') {
      final query = request.uri.queryParameters;
      final limit = _parseBoundedInt(
        query['limit'],
        fallback: 25,
        min: 1,
        max: 100,
      );
      final offset = _parseBoundedInt(
        query['offset'],
        fallback: 0,
        min: 0,
        max: 100000,
      );
      final filtered = _catalog.courses
          .where((record) {
            if (query['specialization_id'] case final String id
                when id.isNotEmpty) {
              if (record.specializationId != id) return false;
            }
            if (query['year'] case final String raw when raw.isNotEmpty) {
              if (record.year != int.tryParse(raw)) return false;
            }
            if (query['semester'] case final String raw when raw.isNotEmpty) {
              if (record.semester != int.tryParse(raw)) return false;
            }
            return true;
          })
          .toList(growable: false);
      final page = filtered
          .skip(offset)
          .take(limit)
          .map(_catalog.courseSummary)
          .toList(growable: false);
      return (
        200,
        {
          'data': {
            'items': page,
            'total': filtered.length,
            'limit': limit,
            'offset': offset,
          },
        },
      );
    }
    if (segments.length == 4 &&
        segments[0] == 'v1' &&
        segments[1] == 'academic' &&
        segments[2] == 'courses' &&
        method == 'GET') {
      final record = _catalog.courseById(segments[3]);
      if (record == null) {
        throw const ApiException(
          404,
          'course_not_found',
          'The course was not found.',
        );
      }
      return (
        200,
        {
          'data': {'course': _catalog.courseDetail(record)},
        },
      );
    }
    if (segments.length == 4 &&
        segments[0] == 'v1' &&
        segments[1] == 'academic' &&
        segments[2] == 'lessons' &&
        method == 'GET') {
      final record = _catalog.lessonById(segments[3]);
      if (record == null) {
        throw const ApiException(
          404,
          'lesson_not_found',
          'The lesson was not found.',
        );
      }
      return (
        200,
        {
          'data': {
            'courseId': record.course.course.id,
            'lesson': _catalog.lessonJson(record.lesson),
          },
        },
      );
    }
    if (_isPath(segments, ['v1', 'students', 'me']) && method == 'GET') {
      return (
        200,
        {
          'data': {'studentId': principal.userId, 'email': principal.email},
        },
      );
    }
    if (_isPath(segments, ['v1', 'students', 'me', 'profile'])) {
      if (method == 'GET') {
        final rows = await _gateway.selectRows(
          table: 'student_profiles',
          accessToken: accessToken,
          query: {
            'select': 'profile,updated_at',
            'student_id': 'eq.${principal.userId}',
            'limit': '1',
          },
        );
        final row = rows.isEmpty ? null : rows.first;
        return (
          200,
          {
            'data': {
              'studentId': principal.userId,
              'profile': row?['profile'],
              'updatedAt': row?['updated_at'],
            },
          },
        );
      }
      if (method == 'PUT') {
        final profile = _validateProfile(await _readJson(request));
        final updatedAt = DateTime.now().toUtc().toIso8601String();
        final row = await _gateway.upsertUserRow(
          table: 'student_profiles',
          accessToken: accessToken,
          onConflict: 'student_id',
          row: {
            'student_id': principal.userId,
            'profile': profile,
            'updated_at': updatedAt,
          },
        );
        return (
          200,
          {
            'data': {
              'studentId': principal.userId,
              'profile': profile,
              'updatedAt': row?['updated_at'] ?? updatedAt,
            },
          },
        );
      }
    }
    if (_isPath(segments, ['v1', 'students', 'me', 'learning-plan']) &&
        method == 'GET') {
      final rows = await _gateway.selectRows(
        table: 'student_learning_plans',
        accessToken: accessToken,
        query: {
          'select': 'plan,source_assessment_id,updated_at',
          'student_id': 'eq.${principal.userId}',
          'limit': '1',
        },
      );
      final row = rows.isEmpty ? null : rows.first;
      return (
        200,
        {
          'data': {
            'studentId': principal.userId,
            'plan': row?['plan'],
            'sourceAssessmentId': row?['source_assessment_id'],
            'updatedAt': row?['updated_at'],
          },
        },
      );
    }
    if (_isPath(segments, ['v1', 'students', 'me', 'project-plan'])) {
      if (method == 'GET') {
        final rows = await _gateway.selectRows(
          table: 'student_project_assignments',
          accessToken: accessToken,
          query: {
            'select': 'assignment,source_plan_assessment_id,updated_at',
            'student_id': 'eq.${principal.userId}',
            'limit': '1',
          },
        );
        final row = rows.isEmpty ? null : rows.first;
        return (
          200,
          {
            'data': {
              'studentId': principal.userId,
              'assignment': row?['assignment'],
              'sourcePlanAssessmentId': row?['source_plan_assessment_id'],
              'updatedAt': row?['updated_at'],
            },
          },
        );
      }
      if (method == 'POST') {
        final assignment = await _createProjectAssignment(
          principal: principal,
          accessToken: accessToken,
        );
        return (201, {'data': assignment});
      }
    }
    if (_isPath(segments, ['v1', 'students', 'me', 'learning-state'])) {
      if (method == 'GET') {
        final rows = await _gateway.selectRows(
          table: 'student_learning_state',
          accessToken: accessToken,
          query: {
            'select': 'payload,updated_at',
            'student_id': 'eq.${principal.userId}',
            'limit': '1',
          },
        );
        final row = rows.isEmpty ? null : rows.first;
        return (
          200,
          {
            'data': {
              'studentId': principal.userId,
              'state': row?['payload'],
              'updatedAt': row?['updated_at'],
            },
          },
        );
      }
      if (method == 'PUT') {
        final state = _validateLearningState(await _readJson(request));
        final updatedAt = DateTime.now().toUtc().toIso8601String();
        final row = await _gateway.upsertUserRow(
          table: 'student_learning_state',
          accessToken: accessToken,
          onConflict: 'student_id',
          row: {
            'student_id': principal.userId,
            'payload': state,
            'updated_at': updatedAt,
          },
        );
        return (
          200,
          {
            'data': {
              'studentId': principal.userId,
              'state': state,
              'updatedAt': row?['updated_at'] ?? updatedAt,
            },
          },
        );
      }
      if (method == 'DELETE') {
        await _gateway.deleteUserRows(
          table: 'student_learning_state',
          accessToken: accessToken,
          query: {'student_id': 'eq.${principal.userId}'},
        );
        return (
          200,
          {
            'data': {'cleared': true},
          },
        );
      }
    }
    if (segments.length == 5 &&
        segments[0] == 'v1' &&
        segments[1] == 'learning' &&
        segments[2] == 'assessments' &&
        segments[4] == 'attempts') {
      final assessmentId = segments[3];
      final record = _catalog.assessmentById(assessmentId);
      if (record == null) {
        throw const ApiException(
          404,
          'assessment_not_found',
          'The assessment was not found.',
        );
      }
      if (method == 'GET') {
        final rows = await _gateway.selectRows(
          table: 'assessment_attempts',
          accessToken: accessToken,
          query: {
            'select':
                'attempt_id,assessment_id,attempt_number,score,total,percentage,passed,wrong_question_ids,previous_attempt_id,completed_at',
            'student_id': 'eq.${principal.userId}',
            'assessment_id': 'eq.$assessmentId',
            'order': 'attempt_number.desc',
          },
        );
        return (
          200,
          {
            'data': {'items': rows.map(_attemptJson).toList(growable: false)},
          },
        );
      }
      if (method == 'POST') {
        return (
          201,
          {
            'data': await _submitAssessment(
              record: record,
              assessmentId: assessmentId,
              principal: principal,
              accessToken: accessToken,
              body: await _readJson(request),
            ),
          },
        );
      }
    }
    if (_isPath(segments, ['v1', 'projects']) && method == 'GET') {
      final items = _catalog.projects
          .map(
            (record) => {
              'courseId': record.course.course.id,
              'courseName': record.course.course.name,
              'project': _catalog.projectJson(record.project),
            },
          )
          .toList(growable: false);
      return (
        200,
        {
          'data': {'items': items, 'total': items.length},
        },
      );
    }
    if (segments.length == 6 &&
        segments[0] == 'v1' &&
        segments[1] == 'projects' &&
        segments[3] == 'tasks' &&
        segments[5] == 'evidence') {
      final projectId = segments[2];
      final taskId = segments[4];
      final projectRecord = _catalog.projectById(projectId);
      if (projectRecord == null) {
        throw const ApiException(
          404,
          'project_not_found',
          'The project was not found.',
        );
      }
      if (method == 'GET') {
        final rows = await _gateway.selectRows(
          table: 'project_task_evidence',
          accessToken: accessToken,
          query: {
            'select': 'evidence_id,project_id,task_id,evidence,submitted_at',
            'student_id': 'eq.${principal.userId}',
            'project_id': 'eq.$projectId',
            'task_id': 'eq.$taskId',
            'order': 'submitted_at.desc',
          },
        );
        return (
          200,
          {
            'data': {'items': rows},
          },
        );
      }
      if (method == 'POST') {
        final evidence = await _submitProjectTaskEvidence(
          projectId: projectId,
          taskId: taskId,
          principal: principal,
          accessToken: accessToken,
          body: await _readJson(request),
        );
        return (201, {'data': evidence});
      }
    }
    if (segments.length == 4 &&
        segments[0] == 'v1' &&
        segments[1] == 'projects' &&
        segments[3] == 'progress') {
      final projectId = segments[2];
      final projectRecord = _catalog.projectById(projectId);
      if (projectRecord == null) {
        throw const ApiException(
          404,
          'project_not_found',
          'The project was not found.',
        );
      }
      if (method == 'GET') {
        final rows = await _gateway.selectRows(
          table: 'student_project_progress',
          accessToken: accessToken,
          query: {
            'select': 'progress,updated_at',
            'student_id': 'eq.${principal.userId}',
            'project_id': 'eq.$projectId',
            'limit': '1',
          },
        );
        final row = rows.isEmpty ? null : rows.first;
        return (
          200,
          {
            'data': {
              'projectId': projectId,
              'progress': row?['progress'],
              'updatedAt': row?['updated_at'],
            },
          },
        );
      }
      if (method == 'PUT') {
        final progress = _validateProjectProgress(
          await _readJson(request),
          projectRecord.project,
        );
        final updatedAt = DateTime.now().toUtc().toIso8601String();
        final row = await _gateway.upsertUserRow(
          table: 'student_project_progress',
          accessToken: accessToken,
          onConflict: 'student_id,project_id',
          row: {
            'student_id': principal.userId,
            'project_id': projectId,
            'progress': progress,
            'updated_at': updatedAt,
          },
        );
        return (
          200,
          {
            'data': {
              'projectId': projectId,
              'progress': progress,
              'updatedAt': row?['updated_at'] ?? updatedAt,
            },
          },
        );
      }
    }
    if (segments.length == 3 &&
        segments[0] == 'v1' &&
        segments[1] == 'projects' &&
        method == 'GET') {
      final record = _catalog.projectById(segments[2]);
      if (record == null) {
        throw const ApiException(
          404,
          'project_not_found',
          'The project was not found.',
        );
      }
      return (
        200,
        {
          'data': {
            'courseId': record.course.course.id,
            'courseName': record.course.course.name,
            'project': _catalog.projectJson(record.project),
          },
        },
      );
    }

    throw const ApiException(
      404,
      'route_not_found',
      'The API route was not found.',
    );
  }

  Future<Map<String, dynamic>> _submitProjectTaskEvidence({
    required String projectId,
    required String taskId,
    required ApiPrincipal principal,
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    const evidenceKeys = {'type', 'title', 'description', 'uri', 'checksum'};
    if (body.keys.toSet().difference(evidenceKeys).isNotEmpty ||
        !body.keys.toSet().containsAll(const {
          'type',
          'title',
          'description',
        })) {
      throw const ApiException(
        400,
        'invalid_payload',
        'The request contains missing or unsupported fields.',
      );
    }
    final type = body['type'];
    if (type is! String ||
        !const {'text', 'url', 'test_result', 'artifact'}.contains(type)) {
      throw const ApiException(
        400,
        'invalid_evidence',
        'Evidence type is not supported.',
      );
    }
    final title = _requiredText(body, 'title', maxLength: 160);
    final description = _requiredText(body, 'description', maxLength: 4000);
    final assignments = await _gateway.selectRows(
      table: 'student_project_assignments',
      accessToken: accessToken,
      query: {
        'select': 'assignment',
        'student_id': 'eq.${principal.userId}',
        'limit': '1',
      },
    );
    if (assignments.isEmpty || assignments.first['assignment'] is! Map) {
      throw const ApiException(
        409,
        'project_assignment_required',
        'A project assignment is required before submitting evidence.',
      );
    }
    final assignment = Map<String, dynamic>.from(
      assignments.first['assignment'] as Map,
    );
    if (assignment['projectId'] != projectId || assignment['tasks'] is! List) {
      throw const ApiException(
        403,
        'task_not_assigned',
        "The project is not the student's current assignment.",
      );
    }
    final tasks = (assignment['tasks'] as List)
        .whereType<Map>()
        .map((task) => Map<String, dynamic>.from(task))
        .toList(growable: false);
    if (!tasks.any((task) => task['id'] == taskId)) {
      throw const ApiException(
        403,
        'task_not_assigned',
        'Evidence can only be submitted for an assigned canonical task.',
      );
    }
    final evidence = {
      'type': type,
      'title': title,
      'description': description,
      if (body['uri'] case final String uri when uri.trim().isNotEmpty)
        'uri': uri.trim(),
      if (body['checksum'] case final String checksum
          when checksum.trim().isNotEmpty)
        'checksum': checksum.trim(),
    };
    final row = await _gateway.insertProjectTaskEvidence({
      'student_id': principal.userId,
      'project_id': projectId,
      'task_id': taskId,
      'evidence': evidence,
    }, accessToken: accessToken);
    return {
      'evidenceId': row?['evidence_id'],
      'projectId': projectId,
      'taskId': taskId,
      'evidence': evidence,
      'submittedAt': row?['submitted_at'],
    };
  }

  Future<Map<String, dynamic>> _createProjectAssignment({
    required ApiPrincipal principal,
    required String accessToken,
  }) async {
    final planRows = await _gateway.selectRows(
      table: 'student_learning_plans',
      accessToken: accessToken,
      query: {
        'select': 'plan,source_assessment_id',
        'student_id': 'eq.${principal.userId}',
        'limit': '1',
      },
    );
    if (planRows.isEmpty || planRows.first['plan'] is! Map) {
      throw const ApiException(
        409,
        'learning_plan_required',
        'A saved learning plan is required before assigning a project.',
      );
    }
    final plan = Map<String, dynamic>.from(planRows.first['plan'] as Map);
    final gaps = plan['gaps'] is Map
        ? Map<String, dynamic>.from(plan['gaps'] as Map)
        : const <String, dynamic>{};
    final skillIds = (gaps['skillIds'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toSet();
    final conceptIds = (gaps['conceptIds'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toSet();

    final projects = _catalog.projects;
    if (projects.isEmpty) {
      throw const ApiException(
        409,
        'project_unavailable',
        'No canonical project is available for assignment.',
      );
    }
    final ranked = projects.map((record) {
      final project = record.project;
      final overlap =
          project.skillIds.where(skillIds.contains).length * 2 +
          project.conceptIds.where(conceptIds.contains).length;
      return (record: record, overlap: overlap);
    }).toList()..sort((a, b) => b.overlap.compareTo(a.overlap));
    final selected = ranked.first.record;
    final project = selected.project;
    final tasks = project.implementationTasks
        .asMap()
        .entries
        .map(
          (entry) => {
            'id': '${project.id}-task-${entry.key + 1}',
            'title': entry.value,
            'status': 'pending',
            'source': 'canonical_project',
          },
        )
        .toList(growable: false);
    final assignment = {
      'project': _catalog.projectJson(project),
      'projectId': project.id,
      'courseId': selected.course.course.id,
      'title': project.title,
      'description': project.description,
      'requirements': project.requirements,
      'deliverables': project.deliverables,
      'acceptanceCriteria': project.acceptanceCriteria,
      'tasks': tasks,
      'testCases': project.testCases,
      'evidenceRequirements': project.evidenceRequirements,
      'sourcePlanAssessmentId': plan['assessmentId'],
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _gateway.upsertDerivedProjectAssignment({
      'student_id': principal.userId,
      'assignment': assignment,
      'source_plan_assessment_id':
          planRows.first['source_assessment_id'] ?? plan['assessmentId'],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    return {'studentId': principal.userId, 'assignment': assignment};
  }

  Future<Map<String, dynamic>> _submitAssessment({
    required AcademicAssessmentRecord record,
    required String assessmentId,
    required ApiPrincipal principal,
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    _requireKeys(body, const {'answers'});
    final rawAnswers = body['answers'];
    if (rawAnswers is! Map) {
      throw const ApiException(
        400,
        'invalid_answers',
        'answers must be an object of question ids and option indexes.',
      );
    }
    final questions = record.assessment.questions;
    if (questions.isEmpty) {
      throw const ApiException(
        409,
        'assessment_unavailable',
        'This assessment has no questions.',
      );
    }
    final questionIds = questions.map((question) => question.id).toSet();
    final answers = Map<String, dynamic>.from(rawAnswers);
    if (answers.length != questions.length ||
        !answers.keys.toSet().containsAll(questionIds)) {
      throw const ApiException(
        400,
        'incomplete_answers',
        'Submit exactly one answer for every assessment question.',
      );
    }

    var score = 0;
    final wrongQuestionIds = <String>[];
    for (final question in questions) {
      final answer = answers[question.id];
      if (answer is! int || answer < 0 || answer >= question.options.length) {
        throw const ApiException(
          400,
          'invalid_answer',
          'An answer option is outside the valid range.',
        );
      }
      if (answer == question.correctIndex) {
        score++;
      } else {
        wrongQuestionIds.add(question.id);
      }
    }

    final previousRows = await _gateway.selectRows(
      table: 'assessment_attempts',
      accessToken: accessToken,
      query: {
        'select': 'attempt_id,attempt_number,passed',
        'student_id': 'eq.${principal.userId}',
        'assessment_id': 'eq.$assessmentId',
        'order': 'attempt_number.desc',
        'limit': '1',
      },
    );
    final previous = previousRows.isEmpty ? null : previousRows.first;
    if (previous?['passed'] == true) {
      throw const ApiException(
        409,
        'assessment_already_passed',
        'A passed assessment cannot be submitted again.',
      );
    }
    final previousNumber = previous?['attempt_number'];
    final attemptNumber = previousNumber is num
        ? previousNumber.toInt() + 1
        : 1;
    final total = questions.length;
    final percentage = score / total * 100;
    final completedAt = DateTime.now().toUtc().toIso8601String();
    final attemptId = _uuid.v4();
    final row = await _gateway.insertGradedAssessmentAttempt({
      'attempt_id': attemptId,
      'student_id': principal.userId,
      'course_id': record.course.course.id,
      'lesson_id': record.lesson.id,
      'assessment_id': assessmentId,
      'attempt_number': attemptNumber,
      'score': score,
      'total': total,
      'wrong_question_ids': wrongQuestionIds,
      'previous_attempt_id': previous?['attempt_id'],
      'completed_at': completedAt,
    });
    final attempt =
        row ??
        {
          'attempt_id': attemptId,
          'assessment_id': assessmentId,
          'attempt_number': attemptNumber,
          'score': score,
          'total': total,
          'percentage': percentage,
          'passed': percentage >= 60,
          'wrong_question_ids': wrongQuestionIds,
          'previous_attempt_id': previous?['attempt_id'],
          'completed_at': completedAt,
        };
    final result = AssessmentResult(
      assessmentId: assessmentId,
      score: score.toDouble(),
      total: total.toDouble(),
      completedAt: DateTime.parse(completedAt),
      wrongQuestionIds: List<String>.unmodifiable(wrongQuestionIds),
      attemptNumber: attemptNumber,
      isReassessment: attemptNumber > 1,
      previousAttemptId: previous?['attempt_id'] as String?,
    );
    final analysis = const AssessmentAnalysisEngine().analyze(result);
    final gaps = LearningGapReport(
      conceptGapIds: analysis.conceptGapIds,
      skillGapIds: analysis.skillGapIds,
      prerequisiteCourseIds: record.course.course.prerequisiteCourseIds,
    );
    final plan = const LearningIntelligenceEngine().planFor(gaps);
    final planJson = {
      'assessmentId': assessmentId,
      'generatedAt': completedAt,
      'performance': analysis.performance.name,
      'percentage': analysis.percentage,
      'message': analysis.message,
      'gaps': {
        'conceptIds': gaps.conceptGapIds,
        'skillIds': gaps.skillGapIds,
        'prerequisiteCourseIds': gaps.prerequisiteCourseIds,
      },
      'priorityConceptIds': plan.priorityConceptIds,
      'prioritySkillIds': plan.prioritySkillIds,
      'prerequisiteCourseIds': plan.prerequisiteCourseIds,
      'remediationTargets': analysis.remediationTargets,
    };
    await _gateway.upsertDerivedLearningPlan({
      'student_id': principal.userId,
      'plan': planJson,
      'source_assessment_id': assessmentId,
      'updated_at': completedAt,
    });
    final response = _attemptJson(attempt);
    response['analysis'] = {
      'assessmentId': analysis.assessmentId,
      'percentage': analysis.percentage,
      'performance': analysis.performance.name,
      'conceptGapIds': analysis.conceptGapIds,
      'skillGapIds': analysis.skillGapIds,
      'learningOutcomeGapIds': analysis.learningOutcomeGapIds,
      'remediationTargets': analysis.remediationTargets,
      'message': analysis.message,
    };
    response['learningPlan'] = planJson;
    return response;
  }

  Map<String, dynamic> _attemptJson(Map<String, dynamic> row) => {
    'attemptId': row['attempt_id'],
    'assessmentId': row['assessment_id'],
    'attemptNumber': row['attempt_number'],
    'score': row['score'],
    'total': row['total'],
    'percentage': row['percentage'],
    'passed': row['passed'],
    'wrongQuestionIds': row['wrong_question_ids'] ?? const [],
    'previousAttemptId': row['previous_attempt_id'],
    'completedAt': row['completed_at'],
    'isReassessment': (row['attempt_number'] as num? ?? 1) > 1,
  };

  Map<String, dynamic> _validateProfile(Map<String, dynamic> body) {
    _requireKeys(body, const {
      'name',
      'university',
      'college',
      'specialization',
      'currentYear',
      'currentSemester',
    });
    final name = _requiredText(body, 'name', maxLength: 120);
    final university = _requiredText(body, 'university', maxLength: 180);
    final college = _requiredText(body, 'college', maxLength: 180);
    final specialization = _requiredText(
      body,
      'specialization',
      maxLength: 180,
    );
    final year = body['currentYear'];
    final semester = body['currentSemester'];
    if (year is! int ||
        year < 1 ||
        year > 4 ||
        semester is! int ||
        semester < 1 ||
        semester > 2) {
      throw const ApiException(
        400,
        'invalid_profile',
        'The academic year or semester is outside the supported range.',
      );
    }
    return {
      'name': name,
      'university': university,
      'college': college,
      'specialization': specialization,
      'currentYear': year,
      'currentSemester': semester,
    };
  }

  Map<String, dynamic> _validateLearningState(Map<String, dynamic> body) {
    _requireKeys(body, const {'concepts', 'skills', 'capabilities', 'history'});
    final concepts = _metricEntries(
      body['concepts'],
      idKey: 'conceptId',
      levelKey: 'knowledgeLevel',
      allowed: const {'conceptId', 'knowledgeLevel', 'lastUpdated'},
    );
    final skills = _metricEntries(
      body['skills'],
      idKey: 'skillId',
      levelKey: 'level',
      allowed: const {'skillId', 'level', 'status', 'lastUpdated'},
      statuses: const {'missing', 'developing', 'acquired', 'demonstrated'},
    );
    final capabilities =
        _listOfMaps(body['capabilities'], 'capabilities', maxItems: 2000)
            .map((entry) {
              _requireKeys(entry, const {
                'capabilityId',
                'verified',
                'lastUpdated',
              });
              final id = _requiredText(entry, 'capabilityId', maxLength: 128);
              final verified = entry['verified'];
              if (verified is! bool || verified) {
                throw const ApiException(
                  400,
                  'invalid_learning_state',
                  'Capability verification must be established by a trusted assessment, not a client payload.',
                );
              }
              return {
                'capabilityId': id,
                'verified': false,
                'lastUpdated': _optionalTimestamp(entry['lastUpdated']),
              };
            })
            .toList(growable: false);
    final history = _listOfMaps(body['history'], 'history', maxItems: 2000)
        .map((entry) {
          _requireKeys(entry, const {
            'sourceId',
            'sourceType',
            'at',
            'conceptIds',
            'skillIds',
            'capabilityIds',
          });
          final at = entry['at'];
          if (at is! int || at < 0) {
            throw const ApiException(
              400,
              'invalid_learning_state',
              'History timestamps must be non-negative epoch milliseconds.',
            );
          }
          return {
            'sourceId': _requiredText(entry, 'sourceId', maxLength: 128),
            'sourceType': _requiredText(entry, 'sourceType', maxLength: 64),
            'at': at,
            'conceptIds': _stringIds(entry['conceptIds'], 'conceptIds'),
            'skillIds': _stringIds(entry['skillIds'], 'skillIds'),
            'capabilityIds': _stringIds(
              entry['capabilityIds'],
              'capabilityIds',
            ),
          };
        })
        .toList(growable: false);
    return {
      'concepts': concepts,
      'skills': skills,
      'capabilities': capabilities,
      'history': history,
    };
  }

  List<Map<String, dynamic>> _metricEntries(
    dynamic raw, {
    required String idKey,
    required String levelKey,
    required Set<String> allowed,
    Set<String>? statuses,
  }) {
    return _listOfMaps(raw, idKey, maxItems: 5000)
        .map((entry) {
          _requireKeys(entry, allowed);
          final id = _requiredText(entry, idKey, maxLength: 128);
          final level = entry[levelKey];
          if (level is! num ||
              !level.toDouble().isFinite ||
              level < 0 ||
              level > 100) {
            throw const ApiException(
              400,
              'invalid_learning_state',
              'Learning levels must be between 0 and 100.',
            );
          }
          final result = <String, dynamic>{
            idKey: id,
            levelKey: level.toDouble(),
          };
          if (statuses != null) {
            final status = entry['status'];
            if (status is! String || !statuses.contains(status)) {
              throw const ApiException(
                400,
                'invalid_learning_state',
                'A skill status is invalid.',
              );
            }
            result['status'] = status;
          }
          result['lastUpdated'] = _optionalTimestamp(entry['lastUpdated']);
          return result;
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _validateProjectProgress(
    Map<String, dynamic> body,
    AcademicProject project,
  ) {
    _requireKeys(body, const {'status', 'completedTasks', 'notes'});
    final status = body['status'];
    if (status is! String ||
        !const {'in_progress', 'submitted'}.contains(status)) {
      throw const ApiException(
        400,
        'invalid_project_progress',
        'Project status must be in_progress or submitted.',
      );
    }
    final rawTasks = body['completedTasks'];
    if (rawTasks is! List ||
        rawTasks.length > project.implementationTasks.length) {
      throw const ApiException(
        400,
        'invalid_project_progress',
        'completedTasks must be a list of tasks from the canonical project.',
      );
    }
    final tasks = <String>[];
    for (final task in rawTasks) {
      if (task is! String ||
          !project.implementationTasks.contains(task) ||
          tasks.contains(task)) {
        throw const ApiException(
          400,
          'invalid_project_progress',
          'A completed task is not part of the canonical project.',
        );
      }
      tasks.add(task);
    }
    final notes = body['notes'];
    if (notes is! String || notes.length > 2000) {
      throw const ApiException(
        400,
        'invalid_project_progress',
        'Project notes must be text of at most 2000 characters.',
      );
    }
    return {'status': status, 'completedTasks': tasks, 'notes': notes};
  }

  Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
    final mimeType = request.headers.contentType?.mimeType.toLowerCase();
    if (mimeType != 'application/json' &&
        !(mimeType?.endsWith('+json') ?? false)) {
      throw const ApiException(
        415,
        'unsupported_media_type',
        'Send a JSON request body.',
      );
    }
    const maxBodyBytes = 256 * 1024;
    final builder = BytesBuilder(copy: false);
    var size = 0;
    await for (final chunk in request) {
      size += chunk.length;
      if (size > maxBodyBytes) {
        throw const ApiException(
          413,
          'payload_too_large',
          'The request body exceeds the 256 KiB limit.',
        );
      }
      builder.add(chunk);
    }
    final decoded = jsonDecode(utf8.decode(builder.takeBytes()));
    if (decoded is! Map) {
      throw const ApiException(
        400,
        'invalid_json',
        'The JSON request body must be an object.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  String _extractBearer(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader) ?? '';
    final match = RegExp(
      r'^Bearer\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(header);
    if (match == null) {
      throw const ApiException(
        401,
        'unauthorized',
        'A Supabase bearer token is required.',
      );
    }
    return match.group(1)!.trim();
  }

  Future<void> _write(
    HttpRequest request,
    int status,
    Map<String, dynamic> body, {
    bool preflight = false,
  }) async {
    final response = request.response;
    final origin = request.headers.value('Origin');
    response.statusCode = status;
    response.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/json; charset=utf-8',
    );
    response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    response.headers.set('X-Content-Type-Options', 'nosniff');
    if (origin != null && _allowedOrigins.contains(origin)) {
      response.headers.set(HttpHeaders.accessControlAllowOriginHeader, origin);
      response.headers.set(HttpHeaders.varyHeader, 'Origin');
    }
    if (preflight && status == 204) {
      response.headers.set(
        HttpHeaders.accessControlAllowMethodsHeader,
        'GET, POST, PUT, DELETE, OPTIONS',
      );
      response.headers.set(
        HttpHeaders.accessControlAllowHeadersHeader,
        'Authorization, Content-Type',
      );
      response.headers.set(HttpHeaders.accessControlMaxAgeHeader, '600');
    } else if (status != 204) {
      response.write(jsonEncode(body));
    }
    await response.close();
  }

  Map<String, dynamic> _error(String code, String message) => {
    'error': {'code': code, 'message': message},
  };

  bool _isPath(List<String> actual, List<String> expected) =>
      actual.length == expected.length &&
      List.generate(
        actual.length,
        (index) => actual[index] == expected[index],
      ).every((value) => value);

  int _parseBoundedInt(
    String? raw, {
    required int fallback,
    required int min,
    required int max,
  }) {
    if (raw == null) return fallback;
    final value = int.tryParse(raw);
    if (value == null || value < min || value > max) {
      throw ApiException(
        400,
        'invalid_query',
        'Query value must be between $min and $max.',
      );
    }
    return value;
  }

  void _requireKeys(Map<String, dynamic> body, Set<String> keys) {
    if (body.keys.toSet().difference(keys).isNotEmpty ||
        keys.difference(body.keys.toSet()).isNotEmpty) {
      throw const ApiException(
        400,
        'invalid_payload',
        'The request contains missing or unsupported fields.',
      );
    }
  }

  String _requiredText(
    Map<String, dynamic> body,
    String key, {
    required int maxLength,
  }) {
    final value = body[key];
    if (value is! String || value.trim().isEmpty || value.length > maxLength) {
      throw ApiException(
        400,
        'invalid_payload',
        '$key must be non-empty text of at most $maxLength characters.',
      );
    }
    return value.trim();
  }

  List<Map<String, dynamic>> _listOfMaps(
    dynamic value,
    String label, {
    required int maxItems,
  }) {
    if (value is! List ||
        value.length > maxItems ||
        value.any((item) => item is! Map)) {
      throw ApiException(
        400,
        'invalid_learning_state',
        '$label must be a list within the supported size.',
      );
    }
    return value
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  List<String> _stringIds(dynamic value, String label) {
    if (value is! List ||
        value.length > 256 ||
        value.any(
          (item) => item is! String || item.trim().isEmpty || item.length > 128,
        )) {
      throw ApiException(
        400,
        'invalid_learning_state',
        '$label must contain valid identifiers.',
      );
    }
    return value
        .cast<String>()
        .map((item) => item.trim())
        .toList(growable: false);
  }

  int? _optionalTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is! int || value < 0) {
      throw const ApiException(
        400,
        'invalid_learning_state',
        'Timestamps must be non-negative epoch milliseconds.',
      );
    }
    return value;
  }
}
