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
  const AcademicSpecialization({
    required this.id,
    required this.name,
    required this.years,
    this.foundationCourseIds = const [],
  });
  final String id;
  final String name;
  final List<AcademicYear> years;
  /// Shared canonical foundation courses required before or alongside specialization study.
  /// These are referenced, not copied into each specialization curriculum.
  final List<String> foundationCourseIds;
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
  const AcademicCourse({
    required this.id,
    required this.name,
    required this.lessons,
    this.units = const [],
    this.prerequisiteCourseIds = const [],
    this.knowledgeAreaIds = const [],
    this.knowledgeUnitIds = const [],
    this.curriculumProfile,
    this.provenance = const AcademicContentProvenance(),
    this.projects = const [],
    this.skills = const [],
    this.capabilities = const [],
  });
  final String id;
  final String name;
  final List<AcademicLesson> lessons;
  final List<AcademicUnit> units;
  final List<String> prerequisiteCourseIds;
  final List<String> knowledgeAreaIds;
  final List<String> knowledgeUnitIds;
  final AcademicCourseProfile? curriculumProfile;
  final AcademicContentProvenance provenance;
  final List<AcademicProject> projects;
  /// Canonical skill definitions owned by this course; lessons reference them by stable id.
  final List<AcademicSkill> skills;
  /// Canonical capability definitions owned by this course; capabilities require explicit skills/evidence.
  final List<AcademicCapability> capabilities;

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
    this.learningOutcomeDefinitions = const [],
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
  final String definition;
  final List<String> applications;
  final String errorAnalysisGuidance;
  final List<String> learningOutcomes;
  /// Structured outcomes with stable ids and explicit concept alignment.
  final List<AcademicLearningOutcome> learningOutcomeDefinitions;
  final List<String> keyTerms;
  final List<String> examples;
  final List<LessonPractice> practices;
  final List<LessonAssessment> assessments;
  final List<AcademicProject> projects;
  final List<String> conceptIds;
  final List<String> skillIds;
  final List<String> skillEvidence;
  final AcademicContentProvenance provenance;
}

/// A structured learning outcome. Legacy learningOutcomes remains supported.
class AcademicLearningOutcome {
  const AcademicLearningOutcome({
    required this.id,
    required this.text,
    this.conceptIds = const [],
  });
  final String id;
  final String text;
  final List<String> conceptIds;
}

/// Canonical skill definition attached to its owning course.
class AcademicSkill {
  const AcademicSkill({
    required this.id,
    required this.name,
    this.learningOutcomeIds = const [],
    this.evidenceRequirements = const [],
  });
  final String id;
  final String name;
  final List<String> learningOutcomeIds;
  final List<String> evidenceRequirements;
}

/// Canonical capability definition. It is never inferred from a project alone.
class AcademicCapability {
  const AcademicCapability({
    required this.id,
    required this.name,
    this.requiredSkillIds = const [],
    this.evidenceRequirements = const [],
  });
  final String id;
  final String name;
  final List<String> requiredSkillIds;
  final List<String> evidenceRequirements;
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
  final List<int> learningOutcomeIndexes;
  final List<String> conceptIds;
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
    this.implementationTasks = const [],
    this.testCases = const [],
    this.evidenceRequirements = const [],
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
  final List<String> implementationTasks;
  final List<String> testCases;
  final List<String> evidenceRequirements;
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
