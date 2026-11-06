import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tofan_ai/backend/api/api_models.dart';
import 'package:tofan_ai/backend/api/owner_authorization.dart';
import 'package:tofan_ai/backend/api/server_owner_command_gate.dart';
import 'package:tofan_ai/backend/api/tofan_api_gateway_server.dart';
import 'package:tofan_ai/abqari/academic_knowledge_engine.dart';
import 'package:tofan_ai/data/academic/academic_library_security_catalog.dart';

const _ownerId = '00000000-0000-4000-8000-000000000001';
const _studentId = '00000000-0000-4000-8000-000000000002';
const _route = '/v1/owner/commands/academic-library-search';

void main() {
  late http.Client authClient;
  late http.Client client;
  late TofanApiGatewayServer api;
  late HttpServer server;
  late Uri baseUri;
  late List<Map<String, Object?>> audit;

  Future<void> startApi({String ownerUserId = _ownerId}) async {
    audit = <Map<String, Object?>>[];
    authClient = MockClient((request) async {
      if (request.url.path != '/auth/v1/user') {
        return http.Response('{}', 404);
      }
      final authorization = request.headers['authorization'];
      final token = authorization?.replaceFirst('Bearer ', '');
      if (token == 'invalid-token') {
        return http.Response('{"message":"invalid token"}', 401);
      }
      if (token == 'owner-token') {
        return http.Response(jsonEncode({
          'id': _ownerId,
          'email': 'owner@example.test',
          'app_metadata': {'role': 'owner'},
          'user_metadata': {'role': 'student'},
        }), 200, headers: {'content-type': 'application/json'});
      }
      if (token == 'student-token') {
        return http.Response(jsonEncode({
          'id': _studentId,
          'email': 'student@example.test',
          'app_metadata': {'role': 'student'},
          'user_metadata': {'role': 'owner'},
        }), 200, headers: {'content-type': 'application/json'});
      }
      if (token == 'wrong-owner-token') {
        return http.Response(jsonEncode({
          'id': _studentId,
          'email': 'other-owner@example.test',
          'app_metadata': {'role': 'owner'},
        }), 200, headers: {'content-type': 'application/json'});
      }
      if (token == 'malformed-identity-token') {
        return http.Response(jsonEncode({
          'id': 'not-a-uuid',
          'app_metadata': {'role': 'owner'},
        }), 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('{"message":"invalid token"}', 401);
    });
    api = TofanApiGatewayServer(
      config: SupabaseApiConfig(
        projectUrl: Uri.parse('https://project.example.test'),
        anonKey: 'test-anon-key',
        serviceRoleKey: 'test-server-only-key',
        ownerUserId: ownerUserId,
      ),
      authClient: authClient,
      auditWriter: (event) => audit.add(Map<String, Object?>.from(event)),
    );
    server = await api.start(port: 0);
    baseUri = Uri.parse('http://127.0.0.1:${server.port}');
    client = http.Client();
  }

  Future<http.Response> postCommand(
    Map<String, dynamic> body, {
    String? token = 'owner-token',
  }) {
    return client.post(
      baseUri.resolve(_route),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  setUp(() async => startApi());

  tearDown(() async {
    client.close();
    await api.close();
    authClient.close();
  });

  test('verified owner can execute the fixed academic search command', () async {
    final response = await postCommand({
      'domainId': 'ai-data',
      'query': 'الذكاء الاصطناعي',
      'limit': 5,
    });
    expect(response.statusCode, 200);
    final data = (jsonDecode(response.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    expect(data['commandId'], ServerOwnerCommandGate.academicLibrarySearch);
    expect(data['domainId'], 'ai-data');
    expect(data['items'], isA<List<dynamic>>());
    expect((data['items'] as List).length, lessThanOrEqualTo(5));
    final allowedAreas = AcademicLibrarySecurityCatalog.domains
        .singleWhere((domain) => domain.id == 'ai-data')
        .knowledgeAreaIds
        .toSet();
    for (final raw in data['items'] as List) {
      final item = raw as Map<String, dynamic>;
      expect(
        (item['knowledgeAreaIds'] as List).any(allowedAreas.contains),
        isTrue,
      );
    }
    expect(audit.any((event) => event['decision'] == 'allow'), isTrue);
  });

  test('student cannot execute owner command even if user_metadata claims owner', () async {
    final response = await postCommand({
      'domainId': 'ai-data',
      'query': 'الذكاء الاصطناعي',
    }, token: 'student-token');
    expect(response.statusCode, 403);
    expect(jsonDecode(response.body)['error']['code'], 'owner_required');
    expect(audit.any((event) => event['decision'] == 'deny'), isTrue);
  });

  test('wrong owner identity and malformed Auth identity are rejected', () async {
    final wrongOwner = await postCommand({
      'domainId': 'ai-data',
      'query': 'الذكاء الاصطناعي',
    }, token: 'wrong-owner-token');
    expect(wrongOwner.statusCode, 403);

    final malformedIdentity = await postCommand({
      'domainId': 'ai-data',
      'query': 'الذكاء الاصطناعي',
    }, token: 'malformed-identity-token');
    expect(malformedIdentity.statusCode, 502);
  });

  test('missing bearer and invalid token are rejected before search', () async {
    final missing = await postCommand({
      'domainId': 'ai-data',
      'query': 'الذكاء الاصطناعي',
    }, token: null);
    expect(missing.statusCode, 401);

    final invalid = await postCommand({
      'domainId': 'ai-data',
      'query': 'الذكاء الاصطناعي',
    }, token: 'invalid-token');
    expect(invalid.statusCode, 401);
  });

  test('missing owner configuration fails closed with 503', () async {
    client.close();
    await api.close();
    authClient.close();
    await startApi(ownerUserId: '');
    final response = await postCommand({
      'domainId': 'ai-data',
      'query': 'الذكاء الاصطناعي',
    });
    expect(response.statusCode, 503);
    expect(jsonDecode(response.body)['error']['code'],
        'owner_authorization_not_configured');
  });

  test('unknown domain, invalid schema, query and limit are rejected', () async {
    final unknownDomain = await postCommand({
      'domainId': 'other-user-domain',
      'query': 'test',
    });
    expect(unknownDomain.statusCode, 400);

    final extraAuthority = await postCommand({
      'domainId': 'ai-data',
      'query': 'test',
      'ownerUserId': _ownerId,
      'role': 'owner',
    });
    expect(extraAuthority.statusCode, 400);

    final tooShort = await postCommand({
      'domainId': 'ai-data',
      'query': 'x',
    });
    expect(tooShort.statusCode, 400);

    final badLimit = await postCommand({
      'domainId': 'ai-data',
      'query': 'test',
      'limit': 21,
    });
    expect(badLimit.statusCode, 400);
  });

  test('audit events never contain bearer token or raw query', () async {
    const secretQuery = 'UNIQUE-PRIVATE-SEARCH-STRING';
    const secretToken = 'owner-token';
    final response = await postCommand({
      'domainId': 'ai-data',
      'query': secretQuery,
    }, token: secretToken);
    expect(response.statusCode, 200);
    final auditText = jsonEncode(audit);
    expect(auditText, isNot(contains(secretQuery)));
    expect(auditText, isNot(contains(secretToken)));
    expect(auditText, isNot(contains('test-anon-key')));
    expect(auditText, isNot(contains('test-server-only-key')));
  });

  test('domain search filters before ranking and result truncation', () {
    const engine = AcademicKnowledgeEngine();
    final scoped = engine.searchInDomain(
      'الذكاء الاصطناعي',
      domainId: 'ai-data',
      limit: 20,
    );
    final allowedAreas = AcademicLibrarySecurityCatalog.domains
        .singleWhere((domain) => domain.id == 'ai-data')
        .knowledgeAreaIds
        .toSet();
    expect(
      scoped.every((item) =>
          item.knowledgeAreaIds.any(allowedAreas.contains)),
      isTrue,
    );
    expect(scoped.length, lessThanOrEqualTo(20));
  });

  test('server grants expire and cannot be replayed', () {
    final gate = ServerOwnerCommandGate(
      ownerPolicy: OwnerAuthorizationPolicy(ownerUserId: _ownerId),
      auditWriter: (_) {},
    );
    final issuedAt = DateTime.utc(2026, 11, 6, 12);
    final expired = gate.issueAcademicSearchGrant(
      principal: const ApiPrincipal(userId: _ownerId, role: 'owner'),
      domainId: 'ai-data',
      now: issuedAt,
    );
    expect(
      gate.consumeAcademicSearchGrant(
        grant: expired,
        domainId: 'ai-data',
        now: issuedAt.add(const Duration(seconds: 31)),
      ),
      isFalse,
    );

    final wrongScope = gate.issueAcademicSearchGrant(
      principal: const ApiPrincipal(userId: _ownerId, role: 'owner'),
      domainId: 'ai-data',
      now: issuedAt,
    );
    expect(
      gate.consumeAcademicSearchGrant(
        grant: wrongScope,
        domainId: 'security',
        now: issuedAt.add(const Duration(seconds: 1)),
      ),
      isFalse,
    );

    final wrongCommand = gate.issueAcademicSearchGrant(
      principal: const ApiPrincipal(userId: _ownerId, role: 'owner'),
      domainId: 'ai-data',
      now: issuedAt,
    );
    expect(
      wrongCommand.consume(
        commandId: 'owner.arbitrary-command',
        domainId: 'ai-data',
        now: issuedAt.add(const Duration(seconds: 1)),
      ),
      isFalse,
    );

    final singleUse = gate.issueAcademicSearchGrant(
      principal: const ApiPrincipal(userId: _ownerId, role: 'owner'),
      domainId: 'ai-data',
      now: issuedAt,
    );
    expect(
      gate.consumeAcademicSearchGrant(
        grant: singleUse,
        domainId: 'ai-data',
        now: issuedAt.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    expect(
      gate.consumeAcademicSearchGrant(
        grant: singleUse,
        domainId: 'ai-data',
        now: issuedAt.add(const Duration(seconds: 2)),
      ),
      isFalse,
    );
  });
}
