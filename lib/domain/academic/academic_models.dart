import 'academic_metadata.dart';

class AcademicField {
  const AcademicField({required this.id, required this.name, required this.universities});
  final String id;
  final String name;
  final List<AcademicUniversity> universities;
}

class AcademicUniversity {
  const AcademicUniversity({required this.id, required this.name, required this.colleges});
  final String id;
  final String name;
  final List<AcademicCollege> colleges;
}

class AcademicCollege {
  const AcademicCollege({required this.id, required this.name, required this.specializations});
  final String id;
  final String name;
  final List<AcademicSpecialization> specializations;
}

class AcademicSpecialization {
  const AcademicSpecialization({required this.id, required this.name, required this.years});
  final String id;
  final String name;
  final List<AcademicYear> years;
}

class AcademicYear {
  const AcademicYear({required this.number, required this.semesters});
  final int number;
  final List<AcademicSemester> semesters;
}

class AcademicSemester {
  const AcademicSemester({required this.number, required this.courses});
  final int number;
  final List<AcademicCourse> courses;
}

class AcademicUnit {
  const AcademicUnit({required this.id, required this.title, required this.lessons});
  final String id;
  final String title;
  final List<AcademicLesson> lessons;
}

class AcademicCourse {
  const AcademicCourse({required this.id, required this.name, required this.lessons,
    this.units = const [],
    this.prerequisiteCourseIds = const [],
    this.knowledgeAreaIds = const [],
    this.knowledgeUnitIds = const [],
    this.curriculumProfile,
    this.provenance = const AcademicContentProvenance(),
    this.projects = const [],
  });
  final String id;
  final String name;
  final List<AcademicLesson> lessons;
  final List<AcademicUnit> units;
  final List<String> prerequisiteCourseIds;
  /// CS2023 knowledge-area references used for global coverage and retrieval.
  final List<String> knowledgeAreaIds;
  /// Canonical knowledge-unit references used for precise retrieval and graph edges.
  final List<String> knowledgeUnitIds;
  /// Course weight and delivery metadata. Null means the curriculum designer has not assigned it yet.
  final AcademicCourseProfile? curriculumProfile;
  /// Provenance and publication state for the course definition.
  final AcademicContentProvenance provenance;
  /// Course-level capstone/project blueprints that integrate the course lessons.
  final List<AcademicProject> projects;

  List<AcademicUnit> get normalizedUnits {
    if (units.isNotEmpty) return units;
    if (lessons.isEmpty) return const [];
    return <AcademicUnit>[AcademicUnit(id: '$id-unit-1', title: 'الوحدة الأولى', lessons: lessons)];
  }
}

class AcademicLesson {
  const AcademicLesson({
    required this.id,
    required this.title,
    this.isFree = true,
    this.content = '',
    this.definition = '',
    this.applications = const [],
    this.errorAnalysisGuidance = '',
    this.learningOutcomes = const [],
    this.keyTerms = const [],
    this.examples = const [],
    this.practices = const [],
    this.assessments = const [],
    this.projects = const [],
    this.conceptIds = const [],
    this.skillIds = const [],
    this.skillEvidence = const [],
    this.provenance = const AcademicContentProvenance(),
  });

  final String id;
  final String title;
  final bool isFree;
  final String content;
  /// The primary definition that should precede dependent explanation.
  final String definition;
  /// Concrete application contexts that connect the lesson to practice.
  final List<String> applications;
  /// Guidance used by the analysis stage to explain and correct common errors.
  final String errorAnalysisGuidance;
  final List<String> learningOutcomes;
  final List<String> keyTerms;
  final List<String> examples;
  final List<LessonPractice> practices;
  final List<LessonAssessment> assessments;
  final List<AcademicProject> projects;
  /// Stable concept identifiers used by analysis and skill-update layers.
  final List<String> conceptIds;
  /// Stable skill identifiers that the lesson is expected to develop.
  final List<String> skillIds;
  /// Observable evidence the learner should produce to demonstrate the skill.
  final List<String> skillEvidence;
  /// Source, author, version and publication state for this lesson.
  final AcademicContentProvenance provenance;
}

class LessonAssessment {
  const LessonAssessment({required this.id, required this.title, required this.questions});
  final String id;
  final String title;
  final List<AssessmentQuestion> questions;
}

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.learningOutcomeIndexes = const [],
    this.conceptIds = const [],
    this.skillIds = const [],
  });
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  /// Zero-based lesson learning-outcome indexes measured by this question.
  final List<int> learningOutcomeIndexes;
  /// Concepts assessed by this question.
  final List<String> conceptIds;
  /// Skills evidenced by this question.
  final List<String> skillIds;
}

class LessonPractice {
  const LessonPractice({required this.id, required this.title, required this.tasks});
  final String id;
  final String title;
  final List<PracticeTask> tasks;
}

class PracticeTask {
  const PracticeTask({required this.id, required this.instruction});
  final String id;
  final String instruction;
}

class AcademicProject {
  const AcademicProject({
    required this.id,
    required this.title,
    required this.description,
    this.skillIds = const [],
    this.conceptIds = const [],
    this.requirements = const [],
    this.deliverables = const [],
    this.milestones = const [],
    this.acceptanceCriteria = const [],
    this.recommendedToolCategories = const [],
  });
  final String id;
  final String title;
  final String description;
  final List<String> skillIds;
  final List<String> conceptIds;
  final List<String> requirements;
  final List<String> deliverables;
  final List<String> milestones;
  final List<String> acceptanceCriteria;
  final List<String> recommendedToolCategories;
}


class AcademicKnowledgeUnit {
  const AcademicKnowledgeUnit({
    required this.id,
    required this.areaId,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.learningOutcomes,
  });

  final String id;
  final String areaId;
  final String name;
  final String arabicName;
  final String description;
  final List<String> learningOutcomes;
}

class AcademicKnowledgeArea {
  const AcademicKnowledgeArea({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.units,
  });

  final String id;
  final String name;
  final String arabicName;
  final List<String> units;
}
