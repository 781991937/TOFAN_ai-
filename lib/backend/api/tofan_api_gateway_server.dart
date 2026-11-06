import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../abqari/academic_knowledge_engine.dart';
import '../../abqari/abqari_models.dart';
import '../../data/academic/academic_library_security_catalog.dart';
import 'api_models.dart';
import 'owner_authorization.dart';
import 'server_owner_command_gate.dart';
import 'supabase_rest_gateway.dart';
import 'tofan_api_server.dart';

/// Public API front door. Existing API routes are forwarded unchanged to the
/// existing TofanApiServer; the fixed owner command is intercepted here so
/// that its authorization boundary is explicit and server-only.
class TofanApiGatewayServer {
  TofanApiGatewayServer({
    required SupabaseApiConfig config,
    http.Client? authClient,
    Set<String> allowedOrigins = const {},
    void Function(Map<String, Object?> event)? auditWriter,
  }) : _gateway = SupabaseRestGateway(config: config, client: authClient),
       _innerApi = TofanApiServer(
         config: config,
         allowedOrigins: allowedOrigins,
       ),
       _ownerGate = ServerOwnerCommandGate(
         ownerPolicy: OwnerAuthorizationPolicy(ownerUserId: config.ownerUserId),
         auditWriter: auditWriter,
       ),
       _allowedOrigins = Set.unmodifiable(allowedOrigins);

  static const _ownerRoute = '/v1/owner/commands/academic-library-search';
  static const _maxBodyBytes = 16 * 1024;

  final SupabaseRestGateway _gateway;
  final TofanApiServer _innerApi;
  final ServerOwnerCommandGate _ownerGate;
  final AcademicKnowledgeEngine _knowledgeEngine = const AcademicKnowledgeEngine();
  final Set<String> _allowedOrigins;
  final http.Client _proxyClient = http.Client();
  HttpServer? _server;
  HttpServer? _innerServer;

  Future<HttpServer> start({
    InternetAddress? bindAddress,
    int port = 8080,
  }) async {
    if (_server != null) throw StateError('The API gateway is already running.');
    _innerServer = await _innerApi.start(
      bindAddress: InternetAddress.loopbackIPv4,
      port: 0,
    );
    try {
      _server = await HttpServer.bind(
        bindAddress ?? InternetAddress.loopbackIPv4,
        port,
      );
      _server!.listen(
        (request) => _handle(request),
        onError: (Object _, StackTrace __) {},
      );
      return _server!;
    } catch (_) {
      await _innerApi.close();
      _innerServer = null;
      rethrow;
    }
  }

  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
    await _innerApi.close();
    _innerServer = null;
    _gateway.close();
    _proxyClient.close();
  }

  Future<void> _handle(HttpRequest request) async {
    final origin = request.headers.value('Origin');
    if (origin != null && !_allowedOrigins.contains(origin)) {
      await _write(request, 403, _error(
        'origin_not_allowed',
        'This origin is not allowed.',
      ));
      return;
    }

    if (request.uri.path == _ownerRoute) {
      if (request.method != 'POST') {
        await _write(request, 405, _error(
          'method_not_allowed',
          'This owner command requires POST.',
        ));
        return;
      }
      await _handleOwnerSearch(request);
      return;
    }

    await _proxyToExistingApi(request);
  }

  Future<void> _handleOwnerSearch(HttpRequest request) async {
    try {
      if (request.method == 'OPTIONS') {
        await _write(request, 204, const {}, preflight: true);
        return;
      }
      final token = _extractBearer(request);
      final principal = await _gateway.authenticate(token);
      final body = await _readJson(request);
      if (body.keys.toSet().difference(const {'domainId', 'query', 'limit'}).isNotEmpty ||
          !body.keys.toSet().containsAll(const {'domainId', 'query'})) {
        throw const ApiException(
          400,
          'invalid_payload',
          'The request contains missing or unsupported fields.',
        );
      }

      final domainId = body['domainId'];
      if (domainId is! String ||
          !AcademicLibrarySecurityCatalog.domains.any((domain) => domain.id == domainId)) {
        throw const ApiException(
          400,
          'invalid_resource_scope',
          'The requested academic library domain is not recognized.',
        );
      }
      final query = body['query'];
      if (query is! String ||
          query.trim().runes.length < 2 ||
          query.trim().runes.length > 200) {
        throw const ApiException(
          400,
          'invalid_query',
          'query must contain between 2 and 200 characters.',
        );
      }
      final rawLimit = body['limit'];
      final limit = rawLimit == null ? 20 : rawLimit;
      if (limit is! int || limit < 1 || limit > 20) {
        throw const ApiException(
          400,
          'invalid_limit',
          'limit must be an integer between 1 and 20.',
        );
      }

      final grant = _ownerGate.issueAcademicSearchGrant(
        principal: principal,
        domainId: domainId,
      );
      if (!_ownerGate.consumeAcademicSearchGrant(
        grant: grant,
        domainId: domainId,
      )) {
        throw const ApiException(
          403,
          'owner_command_grant_invalid',
          'The owner command authorization grant is invalid or expired.',
        );
      }

      try {
        final items = _knowledgeEngine.searchInDomain(
          query.trim(),
          domainId: domainId,
          limit: limit,
        );
        _audit({
          'event': 'owner_command_executed',
          'commandId': ServerOwnerCommandGate.academicLibrarySearch,
          'ownerUserId': principal.userId,
          'resourceScope': 'academic_library/$domainId',
          'decision': 'allow',
          'resultCount': items.length,
          'correlationId': grant.correlationId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        });
        await _write(request, 200, {
          'data': {
            'commandId': ServerOwnerCommandGate.academicLibrarySearch,
            'domainId': domainId,
            'items': items.map(_knowledgeItemJson).toList(growable: false),
            'total': items.length,
          },
        });
      } catch (_) {
        _audit({
          'event': 'owner_command_execution_failed',
          'commandId': ServerOwnerCommandGate.academicLibrarySearch,
          'ownerUserId': principal.userId,
          'resourceScope': 'academic_library/$domainId',
          'decision': 'deny',
          'reasonCode': 'search_execution_failed',
          'correlationId': grant.correlationId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        });
        rethrow;
      }
    } on ApiException catch (error) {
      await _write(request, error.statusCode, _error(error.code, error.message));
    } on FormatException {
      await _write(request, 400, _error(
        'invalid_json',
        'The request body is not valid JSON.',
      ));
    } catch (_) {
      await _write(request, 500, _error(
        'internal_error',
        'The server could not complete the owner command.',
      ));
    }
  }

  void _audit(Map<String, Object?> event) {
    // ServerOwnerCommandGate uses the same injected writer. The default sink
    // is stdout; production must forward stdout to a retained log service.
    // This event deliberately excludes the bearer token and raw search query.
    // The gate writer is invoked by its grant operation; execution events are
    // emitted separately here to distinguish authorization from execution.
    _executionAuditWriter?.call(event);
  }

  void Function(Map<String, Object?> event)? get _executionAuditWriter =>
      _auditWriter;

  // Kept as a field through the constructor initializer below.
  void Function(Map<String, Object?> event)? get _auditWriter =>
      _providedAuditWriter;

  late final void Function(Map<String, Object?> event)? _providedAuditWriter;

  Map<String, dynamic> _knowledgeItemJson(AbqariKnowledgeItem item) => {
    'id': item.id,
    'title': item.title,
    'sourcePath': item.sourcePath,
    'definition': item.definition,
    'content': item.content,
    'applications': item.applications,
    'learningOutcomes': item.learningOutcomes,
    'terms': item.terms,
    'conceptIds': item.conceptIds,
    'skillIds': item.skillIds,
    'knowledgeAreaIds': item.knowledgeAreaIds,
    'knowledgeUnitIds': item.knowledgeUnitIds,
    'courseId': item.courseId,
    'unitId': item.unitId,
    'lessonId': item.lessonId,
    'projectTitles': item.projectTitles,
  };

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
    final builder = BytesBuilder(copy: false);
    var size = 0;
    await for (final chunk in request) {
      size += chunk.length;
      if (size > _maxBodyBytes) {
        throw const ApiException(
          413,
          'payload_too_large',
          'The owner command request body is too large.',
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
    final match = RegExp(r'^Bearer\s+(.+)$', caseSensitive: false).firstMatch(header);
    if (match == null) {
      throw const ApiException(
        401,
        'unauthorized',
        'A Supabase bearer token is required.',
      );
    }
    return match.group(1)!.trim();
  }

  Future<void> _proxyToExistingApi(HttpRequest request) async {
    final inner = _innerServer;
    if (inner == null) {
      await _write(request, 503, _error(
        'api_unavailable',
        'The API service is not available.',
      ));
      return;
    }
    try {
      final target = Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.address,
        port: inner.port,
        path: request.uri.path,
        query: request.uri.hasQuery ? request.uri.query : null,
      );
      final outgoing = http.Request(request.method, target);
      request.headers.forEach((name, values) {
        final lower = name.toLowerCase();
        if (!const {
          'host',
          'content-length',
          'transfer-encoding',
          'connection',
        }.contains(lower)) {
          outgoing.headers[name] = values.join(',');
        }
      });
      final builder = BytesBuilder(copy: false);
      await for (final chunk in request) {
        builder.add(chunk);
      }
      outgoing.bodyBytes = builder.takeBytes();
      final response = await _proxyClient.send(outgoing);
      final bytes = await response.stream.toBytes();
      request.response.statusCode = response.statusCode;
      response.headers.forEach((name, value) {
        final lower = name.toLowerCase();
        if (!const {
          'content-length',
          'transfer-encoding',
          'connection',
        }.contains(lower)) {
          request.response.headers.set(name, value);
        }
      });
      request.response.contentLength = bytes.length;
      request.response.add(bytes);
      await request.response.close();
    } catch (_) {
      await _write(request, 502, _error(
        'api_upstream_unavailable',
        'The API service could not complete the request.',
      ));
    }
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
    response.headers.set('Content-Type', 'application/json; charset=utf-8');
    response.headers.set('Cache-Control', 'no-store');
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
}