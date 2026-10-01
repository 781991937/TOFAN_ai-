import '../../domain/academic/academic_models.dart';

/// Global computer-science knowledge model used by TOFAN Academic Library.
///
/// The identifiers follow the CS2023 knowledge-area abbreviations. The
/// descriptions and instructional packaging are original TOFAN content.
class AcademicKnowledgeAreaCatalog {
  const AcademicKnowledgeAreaCatalog._();

  static const areas = <AcademicKnowledgeArea>[
    AcademicKnowledgeArea(id: 'AI', name: 'Artificial Intelligence', arabicName: 'الذكاء الاصطناعي', units: [
      'Agents and intelligent behavior',
      'Search and problem solving',
      'Knowledge representation and reasoning',
      'Machine learning',
      'Applications and societal impact',
      'Probabilistic representation and reasoning',
      'Planning',
      'Logical representation and reasoning',
      'Agents and cognitive systems',
      'Natural language processing',
      'Robotics',
      'Perception and computer vision',
    ]),
    AcademicKnowledgeArea(id: 'AL', name: 'Algorithmic Foundations', arabicName: 'الأسس الخوارزمية', units: [
      'Algorithms and problem solving',
      'Data structures',
      'Algorithm analysis',
      'Correctness and complexity',
      'Algorithmic paradigms',
    ]),
    AcademicKnowledgeArea(id: 'AR', name: 'Architecture and Organization', arabicName: 'معمارية وتنظيم الحاسوب', units: [
      'Digital representation and logic',
      'Processor organization',
      'Memory hierarchy',
      'Input/output and interconnection',
      'Performance and energy',
    ]),
    AcademicKnowledgeArea(id: 'DM', name: 'Data Management', arabicName: 'إدارة البيانات', units: [
      'Data models',
      'Database systems',
      'Query processing',
      'Data quality and governance',
      'Distributed and large-scale data',
    ]),
    AcademicKnowledgeArea(id: 'FPL', name: 'Foundations of Programming Languages', arabicName: 'أسس لغات البرمجة', units: [
      'Syntax and semantics',
      'Programming paradigms',
      'Type systems',
      'Translation and execution',
      'Program analysis',
    ]),
    AcademicKnowledgeArea(id: 'GIT', name: 'Graphics and Interactive Techniques', arabicName: 'الرسوميات وتقنيات التفاعل', units: [
      'Computer graphics',
      'Geometric representation',
      'Rendering',
      'Interactive media',
      'Virtual and augmented environments',
    ]),
    AcademicKnowledgeArea(id: 'HCI', name: 'Human-Computer Interaction', arabicName: 'تفاعل الإنسان والحاسوب', units: [
      'Users and context',
      'Interaction design',
      'Accessibility and inclusive design',
      'Usability evaluation',
      'Interactive system design',
    ]),
    AcademicKnowledgeArea(id: 'MSF', name: 'Mathematical and Statistical Foundations', arabicName: 'الأسس الرياضية والإحصائية', units: [
      'Discrete mathematics',
      'Probability',
      'Statistics',
      'Linear algebra and mathematical models',
      'Quantitative reasoning',
    ]),
    AcademicKnowledgeArea(id: 'NC', name: 'Networking and Communication', arabicName: 'الشبكات والاتصالات', units: [
      'Network models and protocols',
      'Data communication',
      'Routing and internetworking',
      'Wireless and distributed communication',
      'Network performance and security',
    ]),
    AcademicKnowledgeArea(id: 'OS', name: 'Operating Systems', arabicName: 'أنظمة التشغيل', units: [
      'Processes and threads',
      'Concurrency',
      'Memory management',
      'File and storage systems',
      'Protection and resource management',
    ]),
    AcademicKnowledgeArea(id: 'PDC', name: 'Parallel and Distributed Computing', arabicName: 'الحوسبة المتوازية والموزعة', units: [
      'Parallelism and concurrency',
      'Distributed coordination',
      'Communication and synchronization',
      'Scalability and performance',
      'Fault tolerance',
    ]),
    AcademicKnowledgeArea(id: 'SEC', name: 'Security', arabicName: 'الأمن', units: [
      'Security principles',
      'Threats and vulnerabilities',
      'Cryptography',
      'Secure software and systems',
      'Privacy and risk management',
    ]),
    AcademicKnowledgeArea(id: 'SEP', name: 'Society, Ethics, and the Profession', arabicName: 'المجتمع والأخلاقيات والمهنة', units: [
      'Social context',
      'Ethical analysis',
      'Professional responsibility',
      'Privacy and intellectual property',
      'Law, policy, accessibility, and sustainability',
    ]),
    AcademicKnowledgeArea(id: 'SDF', name: 'Software Development Fundamentals', arabicName: 'أساسيات تطوير البرمجيات', units: [
      'Programming concepts',
      'Data structures and algorithms in practice',
      'Software development practices',
      'Debugging and testing',
      'Programming tools',
    ]),
    AcademicKnowledgeArea(id: 'SE', name: 'Software Engineering', arabicName: 'هندسة البرمجيات', units: [
      'Requirements',
      'Software architecture and design',
      'Construction and testing',
      'Configuration and release management',
      'Maintenance and quality',
    ]),
    AcademicKnowledgeArea(id: 'SPD', name: 'Specialized Platform Development', arabicName: 'تطوير المنصات المتخصصة', units: [
      'Web platforms',
      'Mobile platforms',
      'Embedded platforms',
      'IoT platforms',
      'Platform constraints and deployment',
    ]),
    AcademicKnowledgeArea(id: 'SF', name: 'Systems Fundamentals', arabicName: 'أساسيات الأنظمة', units: [
      'Computer-system foundations',
      'Resource management',
      'System performance',
      'Reliability',
      'System design and integration',
    ]),
  ];

  static AcademicKnowledgeArea? byId(String id) {
    for (final area in areas) {
      if (area.id == id) return area;
    }
    return null;
  }

  static List<AcademicKnowledgeArea> forCourse(AcademicCourse course) =>
      course.knowledgeAreaIds.map(byId).whereType<AcademicKnowledgeArea>().toList(growable: false);
}
