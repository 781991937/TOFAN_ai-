import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../data/academic/academic_library_security_catalog.dart';
import 'api_models.dart';
import 'owner_authorization.dart';

enum ServerOwnerPermission { search }

/// A server-created, single-use capability. Its constructor is private so
/// request JSON or Flutter code cannot manufacture a valid grant.
class ServerOwnerCommandGrant {
  ServerOwnerCommandGrant._({
    required this.commandId,
    required this.domainId,
    required this.issuedAt,
    required this.expiresAt,
    required this.correlationId,
  });

  final String commandId;
  final String domainId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String correlationId;
  bool _consumed = false;

  bool consume({
    required String commandId,
    required String domainId,
    required DateTime now,
  }) {
    if (_consumed ||
        commandId != this.commandId ||
        domainId != this.domainId ||
        !now.isBefore(expiresAt) ||
        now.isBefore(issuedAt)) {
      return false;
    }
    _consumed = true;
    return true;
  }
}

/// Fixed server-side command registry and authorization gate.
/// No command, permission, owner identity, or resource scope is accepted
/// from the caller as an authority-bearing value.
class ServerOwnerCommandGate {
  ServerOwnerCommandGate({
    required OwnerAuthorizationPolicy ownerPolicy,
    void Function(Map<String, Object?> event)? auditWriter,
    Uuid? uuid,
  }) : _ownerPolicy = ownerPolicy,
       _auditWriter = auditWriter ?? _writeStructuredAudit,
       _uuid = uuid ?? const Uuid();

  static const String academicLibrarySearch = 'academic_library.search';
  static const Duration grantLifetime = Duration(seconds: 30);

  static const Set<String> _allowedDomainIds = {
    'core-computing',
    'ai-data',
    'systems-networking',
    'software-engineering',
    'interactive-computing',
    'security',
    'society-profession',
  };

  final OwnerAuthorizationPolicy _ownerPolicy;
  final void Function(Map<String, Object?> event) _auditWriter;
  final Uuid _uuid;

  ServerOwnerCommandGrant issueAcademicSearchGrant({
    required ApiPrincipal principal,
    required String domainId,
    DateTime? now,
  }) {
    final issuedAt = (now ?? DateTime.now()).toUtc();
    final correlationId = _uuid.v4();
    try {
      _ownerPolicy.requireOwner(principal);
      if (!_allowedDomainIds.contains(domainId)) {
        throw const ApiException(
          400,
          'invalid_resource_scope',
          'The requested academic library domain is not recognized.',
        );
      }
      final grant = ServerOwnerCommandGrant._(
        commandId: academicLibrarySearch,
        domainId: domainId,
        issuedAt: issuedAt,
        expiresAt: issuedAt.add(grantLifetime),
        correlationId: correlationId,
      );
      _auditWriter({
        'event': 'owner_command_grant_issued',
        'commandId': academicLibrarySearch,
        'ownerUserId': principal.userId,
        'resourceScope': 'academic_library/$domainId',
        'decision': 'allow',
        'correlationId': correlationId,
        'timestamp': issuedAt.toIso8601String(),
      });
      return grant;
    } on ApiException catch (error) {
      _auditWriter({
        'event': 'owner_command_grant_denied',
        'commandId': academicLibrarySearch,
        'ownerUserId': principal.userId,
        'resourceScope': _allowedDomainIds.contains(domainId)
            ? 'academic_library/$domainId'
            : 'invalid',
        'decision': 'deny',
        'reasonCode': error.code,
        'correlationId': correlationId,
        'timestamp': issuedAt.toIso8601String(),
      });
      rethrow;
    }
  }

  bool consumeAcademicSearchGrant({
    required ServerOwnerCommandGrant grant,
    required String domainId,
    DateTime? now,
  }) =>
      grant.consume(
        commandId: academicLibrarySearch,
        domainId: domainId,
        now: (now ?? DateTime.now()).toUtc(),
      );

  static void _writeStructuredAudit(Map<String, Object?> event) {
    // Production deployment must ship process stdout to its retained log sink.
    stdout.writeln(jsonEncode(event));
  }
}
