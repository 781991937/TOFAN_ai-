/// Security compartment model for the TOFAN Academic Library.
enum LibrarySecurityRole { student, tutor, knowledgeAgent, projectAgent, libraryAdmin, securityAdmin }

enum LibraryAccessOperation { read, search, write, export, administer }

class LibrarySecurityDomain {
  const LibrarySecurityDomain({
    required this.id,
    required this.name,
    required this.description,
    required this.knowledgeAreaIds,
    required this.sensitivity,
  });
  final String id;
  final String name;
  final String description;
  final List<String> knowledgeAreaIds;
  final int sensitivity;
}

class LibrarySecurityRule {
  const LibrarySecurityRule({
    required this.domainId,
    required this.role,
    required this.operation,
    required this.allowed,
  });
  final String domainId;
  final LibrarySecurityRole role;
  final LibraryAccessOperation operation;
  final bool allowed;
}

/// Deny-by-default: access exists only when an explicit rule allows it.
class LibrarySecurityPolicy {
  const LibrarySecurityPolicy({required this.domains, required this.rules});
  final List<LibrarySecurityDomain> domains;
  final List<LibrarySecurityRule> rules;

  bool canAccess(
    LibrarySecurityRole role,
    String domainId,
    LibraryAccessOperation operation,
  ) =>
      rules.any((rule) =>
          rule.domainId == domainId &&
          rule.role == role &&
          rule.operation == operation &&
          rule.allowed);

  LibrarySecurityDomain? domainForKnowledgeArea(String areaId) {
    for (final domain in domains) {
      if (domain.knowledgeAreaIds.contains(areaId)) return domain;
    }
    return null;
  }
}

class LibrarySecurityAuditReport {
  const LibrarySecurityAuditReport({
    required this.domainCount,
    required this.knowledgeAreaCount,
    required this.ruleCount,
    required this.issues,
  });
  final int domainCount;
  final int knowledgeAreaCount;
  final int ruleCount;
  final List<String> issues;
  bool get isHealthy => issues.isEmpty;
}
