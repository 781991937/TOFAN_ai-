import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/data/academic/academic_library_security.dart';
import 'package:tofan_ai/data/academic/academic_library_security_catalog.dart';

void main() {
  test('security compartments cover all 17 canonical knowledge areas', () {
    final report = AcademicLibrarySecurityAudit.run();
    expect(report.domainCount, greaterThan(0));
    expect(report.knowledgeAreaCount, 17);
    expect(report.isHealthy, isTrue, reason: report.issues.join('\n'));
  });

  test('library security is deny-by-default', () {
    final policy = AcademicLibrarySecurityCatalog.policy;
    expect(policy.canAccess(LibrarySecurityRole.student, 'security', LibraryAccessOperation.write), isFalse);
    expect(policy.canAccess(LibrarySecurityRole.knowledgeAgent, 'security', LibraryAccessOperation.administer), isFalse);
    expect(policy.canAccess(LibrarySecurityRole.student, 'unknown-domain', LibraryAccessOperation.read), isFalse);
  });

  test('cybersecurity is a separate high-sensitivity compartment', () {
    final domain = AcademicLibrarySecurityCatalog.domainForArea('SEC');
    expect(domain, isNotNull);
    expect(domain!.id, 'security');
    expect(domain.sensitivity, 5);
  });

  test('learning agents have no library administration or write access', () {
    final policy = AcademicLibrarySecurityCatalog.policy;
    for (final domain in AcademicLibrarySecurityCatalog.domains) {
      expect(policy.canAccess(LibrarySecurityRole.knowledgeAgent, domain.id, LibraryAccessOperation.write), isFalse);
      expect(policy.canAccess(LibrarySecurityRole.knowledgeAgent, domain.id, LibraryAccessOperation.administer), isFalse);
      expect(policy.canAccess(LibrarySecurityRole.projectAgent, domain.id, LibraryAccessOperation.write), isFalse);
    }
  });
}
