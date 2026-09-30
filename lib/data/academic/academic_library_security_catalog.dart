import 'academic_knowledge_area_catalog.dart';
import 'academic_library_security.dart';

/// Canonical security compartments for the academic knowledge layer.
/// Cross-domain retrieval must pass through an explicit policy decision.
class AcademicLibrarySecurityCatalog {
  const AcademicLibrarySecurityCatalog._();

  static const domains = <LibrarySecurityDomain>[
    LibrarySecurityDomain(id: 'core-computing', name: 'Core Computing', description: 'Foundational programming and systems knowledge.', knowledgeAreaIds: ['SDF', 'FPL', 'SF'], sensitivity: 2),
    LibrarySecurityDomain(id: 'ai-data', name: 'AI and Data', description: 'AI, algorithms, data, mathematics, and statistics.', knowledgeAreaIds: ['AI', 'AL', 'DM', 'MSF'], sensitivity: 3),
    LibrarySecurityDomain(id: 'systems-networking', name: 'Systems and Networking', description: 'Architecture, operating systems, networking, and distributed computing.', knowledgeAreaIds: ['AR', 'OS', 'NC', 'PDC'], sensitivity: 4),
    LibrarySecurityDomain(id: 'software-engineering', name: 'Software Engineering', description: 'Software engineering and lifecycle knowledge.', knowledgeAreaIds: ['SE'], sensitivity: 3),
    LibrarySecurityDomain(id: 'interactive-computing', name: 'Interactive Computing', description: 'Graphics, HCI, and specialized platform development.', knowledgeAreaIds: ['GIT', 'HCI', 'SPD'], sensitivity: 2),
    LibrarySecurityDomain(id: 'security', name: 'Cybersecurity', description: 'Security knowledge used to protect the library and systems.', knowledgeAreaIds: ['SEC'], sensitivity: 5),
    LibrarySecurityDomain(id: 'society-profession', name: 'Society Ethics and Profession', description: 'Professional, ethical, and societal computing knowledge.', knowledgeAreaIds: ['SEP'], sensitivity: 2),
  ];

  static final policy = LibrarySecurityPolicy(
    domains: domains,
    rules: [
      ..._rulesFor('core-computing', [LibrarySecurityRole.student, LibrarySecurityRole.tutor, LibrarySecurityRole.knowledgeAgent, LibrarySecurityRole.projectAgent], [LibraryAccessOperation.read, LibraryAccessOperation.search]),
      ..._rulesFor('ai-data', [LibrarySecurityRole.student, LibrarySecurityRole.tutor, LibrarySecurityRole.knowledgeAgent, LibrarySecurityRole.projectAgent], [LibraryAccessOperation.read, LibraryAccessOperation.search]),
      ..._rulesFor('systems-networking', [LibrarySecurityRole.student, LibrarySecurityRole.tutor, LibrarySecurityRole.knowledgeAgent, LibrarySecurityRole.projectAgent], [LibraryAccessOperation.read, LibraryAccessOperation.search]),
      ..._rulesFor('software-engineering', [LibrarySecurityRole.student, LibrarySecurityRole.tutor, LibrarySecurityRole.knowledgeAgent, LibrarySecurityRole.projectAgent], [LibraryAccessOperation.read, LibraryAccessOperation.search]),
      ..._rulesFor('interactive-computing', [LibrarySecurityRole.student, LibrarySecurityRole.tutor, LibrarySecurityRole.knowledgeAgent, LibrarySecurityRole.projectAgent], [LibraryAccessOperation.read, LibraryAccessOperation.search]),
      ..._rulesFor('society-profession', [LibrarySecurityRole.student, LibrarySecurityRole.tutor, LibrarySecurityRole.knowledgeAgent, LibrarySecurityRole.projectAgent], [LibraryAccessOperation.read, LibraryAccessOperation.search]),
      ..._rulesFor('security', [LibrarySecurityRole.tutor, LibrarySecurityRole.knowledgeAgent, LibrarySecurityRole.securityAdmin], [LibraryAccessOperation.read, LibraryAccessOperation.search]),
      ..._rulesFor('core-computing', [LibrarySecurityRole.libraryAdmin], LibraryAccessOperation.values),
      ..._rulesFor('ai-data', [LibrarySecurityRole.libraryAdmin], LibraryAccessOperation.values),
      ..._rulesFor('systems-networking', [LibrarySecurityRole.libraryAdmin], LibraryAccessOperation.values),
      ..._rulesFor('software-engineering', [LibrarySecurityRole.libraryAdmin], LibraryAccessOperation.values),
      ..._rulesFor('interactive-computing', [LibrarySecurityRole.libraryAdmin], LibraryAccessOperation.values),
      ..._rulesFor('society-profession', [LibrarySecurityRole.libraryAdmin], LibraryAccessOperation.values),
      ..._rulesFor('security', [LibrarySecurityRole.securityAdmin], LibraryAccessOperation.values),
    ],
  );

  static List<LibrarySecurityRule> _rulesFor(
    String domainId,
    List<LibrarySecurityRole> roles,
    List<LibraryAccessOperation> operations,
  ) => [
        for (final role in roles)
          for (final operation in operations)
            LibrarySecurityRule(domainId: domainId, role: role, operation: operation, allowed: true),
      ];

  static LibrarySecurityDomain? domainForArea(String areaId) =>
      policy.domainForKnowledgeArea(areaId);
}

class AcademicLibrarySecurityAudit {
  const AcademicLibrarySecurityAudit._();

  static LibrarySecurityAuditReport run() {
    final issues = <String>[];
    final areas = AcademicKnowledgeAreaCatalog.areas;
    final knownAreas = areas.map((a) => a.id).toSet();
    final domainIds = <String>{};
    final mappedAreas = <String>{};
    final ruleKeys = <String>{};

    for (final domain in AcademicLibrarySecurityCatalog.domains) {
      if (!domainIds.add(domain.id)) issues.add('معرف نطاق الحماية مكرر: ${domain.id}.');
      if (domain.knowledgeAreaIds.isEmpty) issues.add('نطاق ${domain.id} بلا مجالات معرفية.');
      if (domain.sensitivity < 1 || domain.sensitivity > 5) issues.add('حساسية غير صالحة في ${domain.id}.');
      for (final areaId in domain.knowledgeAreaIds) {
        if (!knownAreas.contains(areaId)) issues.add('مجال معرفي غير معروف: $areaId.');
        if (!mappedAreas.add(areaId)) issues.add('المجال ${areaId} مرتبط بأكثر من نطاق حماية.');
      }
    }

    for (final areaId in knownAreas.difference(mappedAreas)) {
      issues.add('المجال المعرفي ${areaId} بلا نطاق حماية.');
    }

    for (final rule in AcademicLibrarySecurityCatalog.policy.rules) {
      if (!domainIds.contains(rule.domainId)) issues.add('قاعدة تشير إلى نطاق غير معروف: ${rule.domainId}.');
      final key = '${rule.domainId}|${rule.role.name}|${rule.operation.name}';
      if (!ruleKeys.add(key)) issues.add('قاعدة مكررة: $key.');
    }

    for (final domain in AcademicLibrarySecurityCatalog.domains) {
      for (final role in LibrarySecurityRole.values) {
        for (final operation in [LibraryAccessOperation.read, LibraryAccessOperation.search]) {
          final count = AcademicLibrarySecurityCatalog.policy.rules.where((r) =>
              r.domainId == domain.id && r.role == role && r.operation == operation).length;
          if (count > 1) issues.add('قرار وصول مكرر: ${domain.id}/${role.name}/${operation.name}.');
        }
      }
    }

    for (final domain in AcademicLibrarySecurityCatalog.domains) {
      if (AcademicLibrarySecurityCatalog.policy.canAccess(
        LibrarySecurityRole.knowledgeAgent, domain.id, LibraryAccessOperation.administer)) {
        issues.add('وكيل المعرفة يمتلك صلاحية إدارة المكتبة.');
      }
    }

    return LibrarySecurityAuditReport(
      domainCount: AcademicLibrarySecurityCatalog.domains.length,
      knowledgeAreaCount: areas.length,
      ruleCount: AcademicLibrarySecurityCatalog.policy.rules.length,
      issues: List.unmodifiable(issues),
    );
  }
}
