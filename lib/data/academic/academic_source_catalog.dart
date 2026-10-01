import '../../domain/academic/academic_metadata.dart';

/// Canonical external frameworks used to shape TOFAN's global computing library.
/// These are reference sources, not copied courseware.
class AcademicSourceCatalog {
  const AcademicSourceCatalog._();

  static const cs2023 = AcademicSourceReference(
    id: 'acm-ieee-aaai-cs2023',
    title: 'CS2023: Computer Science Curricula',
    publisher: 'ACM / IEEE Computer Society / AAAI',
    kind: 'curriculum-framework',
    url: 'https://csed.acm.org/',
    version: 'Final Report',
  );

  static const cc2020 = AcademicSourceReference(
    id: 'acm-ieee-cc2020',
    title: 'Computing Curricula 2020',
    publisher: 'ACM / IEEE Computer Society',
    kind: 'computing-curricula-overview',
    url: 'https://www.acm.org/binaries/content/assets/education/curricula-recommendations/cc2020.pdf',
    version: '2020',
  );

  static const cybersecurityCsec2017 = AcademicSourceReference(
    id: 'csec2017',
    title: 'Cybersecurity Curricular Guidelines',
    publisher: 'ACM / IEEE Computer Society / AIS / IFIP',
    kind: 'cybersecurity-curriculum',
    url: 'https://cybered.hosting.acm.org/wp/',
    version: 'CSEC2017',
  );

  static const officialComputingCurricula = AcademicSourceReference(
    id: 'acm-computing-curricula-guidance',
    title: 'ACM Computing Curricula Recommendations',
    publisher: 'ACM',
    kind: 'curriculum-source-index',
    url: 'https://www.acm.org/education/curricula-recommendations',
  );

  static const List<AcademicSourceReference> all = [
    cs2023,
    cc2020,
    cybersecurityCsec2017,
    officialComputingCurricula,
  ];
}
