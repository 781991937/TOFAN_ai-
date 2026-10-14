import '../../data/academic/academic_catalog.dart';
import '../../domain/academic/academic_metadata.dart';
import '../../domain/academic/academic_models.dart';

class AcademicCourseRecord {
  const AcademicCourseRecord({
    required this.course,
    this.fieldId,
    this.universityId,
    this.collegeId,
    this.specializationId,
    this.year,
    this.semester,
  });

  final AcademicCourse course;
  final String? fieldId;
  final String? universityId;
  final String? collegeId;
  final String? specializationId;
  final int? year;
  final int? semester;
}

class AcademicProjectRecord {
  const AcademicProjectRecord({required this.project, required this.course});

  final AcademicProject project;
  final AcademicCourseRecord course;
}

class AcademicAssessmentRecord {
  const AcademicAssessmentRecord({
    required this.assessment,
    required this.course,
    required this.lesson,
  });

  final LessonAssessment assessment;
  final AcademicCourseRecord course;
  final AcademicLesson lesson;
}

/// Read-only API projection over AcademicCatalog; it stores no curriculum data.
class AcademicCatalogApi {
  AcademicCatalogApi() : courses = _buildCourses();

  final List<AcademicCourseRecord> courses;

  List<Map<String, dynamic>> fields() =>
      AcademicCatalog.fields.map(_fieldJson).toList(growable: false);

  List<Map<String, dynamic>> specializations() {
    final result = <Map<String, dynamic>>[];
    for (final field in AcademicCatalog.fields) {
      for (final university in field.universities) {
        for (final college in university.colleges) {
          for (final specialization in college.specializations) {
            result.add(
              _specializationJson(
                fieldId: field.id,
                universityId: university.id,
                collegeId: college.id,
                specialization: specialization,
              ),
            );
          }
        }
      }
    }
    return result;
  }

  List<Map<String, dynamic>> concepts() =>
      AcademicCatalog.concepts.map(conceptJson).toList(growable: false);

  Map<String, dynamic>? conceptById(String id) {
    final concept = AcademicCatalog.conceptById(id);
    return concept == null ? null : conceptJson(concept);
  }

  Map<String, dynamic> conceptJson(AcademicConcept concept) => {
    'id': concept.id,
    'title': concept.title,
    'definition': concept.definition,
    'sourceCourseIds': concept.sourceCourseIds,
    'sourceLessonIds': concept.sourceLessonIds,
    'courseKnowledgeAreaIds': concept.courseKnowledgeAreaIds,
    'courseKnowledgeUnitIds': concept.courseKnowledgeUnitIds,
    'learningOutcomeIds': concept.learningOutcomeIds,
    'relatedSkillIds': concept.relatedSkillIds,
    'assessmentQuestionIds': concept.assessmentQuestionIds,
    'projectIds': concept.projectIds,
    'sourceReferenceIds': concept.sourceReferenceIds,
  };

  AcademicCourseRecord? courseById(String id) {
    for (final record in courses) {
      if (record.course.id == id) return record;
    }
    return null;
  }

  Map<String, dynamic> courseSummary(AcademicCourseRecord record) => {
    'id': record.course.id,
    'name': record.course.name,
    'fieldId': record.fieldId,
    'universityId': record.universityId,
    'collegeId': record.collegeId,
    'specializationId': record.specializationId,
    'year': record.year,
    'semester': record.semester,
    'prerequisiteCourseIds': record.course.prerequisiteCourseIds,
    'knowledgeAreaIds': record.course.knowledgeAreaIds,
    'knowledgeUnitIds': record.course.knowledgeUnitIds,
  };

  Map<String, dynamic> courseDetail(AcademicCourseRecord record) => {
    ...courseSummary(record),
    'curriculumProfile': _profileJson(record.course.curriculumProfile),
    'provenance': _provenanceJson(record.course.provenance),
    'skills': record.course.skills.map(_skillJson).toList(growable: false),
    'capabilities': record.course.capabilities
        .map(_capabilityJson)
        .toList(growable: false),
    'units': record.course.normalizedUnits
        .map(
          (unit) => {
            'id': unit.id,
            'title': unit.title,
            'lessons': unit.lessons.map(lessonJson).toList(growable: false),
          },
        )
        .toList(growable: false),
    'projects': record.course.projects.map(projectJson).toList(growable: false),
  };

  ({AcademicCourseRecord course, AcademicLesson lesson})? lessonById(
    String id,
  ) {
    for (final record in courses) {
      for (final unit in record.course.normalizedUnits) {
        for (final lesson in unit.lessons) {
          if (lesson.id == id) return (course: record, lesson: lesson);
        }
      }
    }
    return null;
  }

  Map<String, dynamic> lessonJson(AcademicLesson lesson) => {
    'id': lesson.id,
    'title': lesson.title,
    'isFree': lesson.isFree,
    'content': lesson.content,
    'definition': lesson.definition,
    'applications': lesson.applications,
    'errorAnalysisGuidance': lesson.errorAnalysisGuidance,
    'learningOutcomes': lesson.learningOutcomes,
    'learningOutcomeDefinitions': lesson.learningOutcomeDefinitions
        .map(
          (outcome) => {
            'id': outcome.id,
            'text': outcome.text,
            'conceptIds': outcome.conceptIds,
          },
        )
        .toList(growable: false),
    'keyTerms': lesson.keyTerms,
    'examples': lesson.examples,
    'practices': lesson.practices
        .map(
          (practice) => {
            'id': practice.id,
            'title': practice.title,
            'tasks': practice.tasks
                .map((task) => {'id': task.id, 'instruction': task.instruction})
                .toList(growable: false),
          },
        )
        .toList(growable: false),
    'assessments': lesson.assessments
        .map(_assessmentJson)
        .toList(growable: false),
    'projects': lesson.projects.map(projectJson).toList(growable: false),
    'conceptIds': lesson.conceptIds,
    'skillIds': lesson.skillIds,
    'skillEvidence': lesson.skillEvidence,
    'provenance': _provenanceJson(lesson.provenance),
  };

  List<AcademicProjectRecord> get projects {
    final result = <String, AcademicProjectRecord>{};
    for (final record in courses) {
      final projectDefinitions = <AcademicProject>[
        ...record.course.projects,
        ...record.course.normalizedUnits
            .expand((unit) => unit.lessons)
            .expand((lesson) => lesson.projects),
      ];
      for (final project in projectDefinitions) {
        result.putIfAbsent(
          project.id,
          () => AcademicProjectRecord(project: project, course: record),
        );
      }
    }
    return result.values.toList(growable: false);
  }

  AcademicProjectRecord? projectById(String id) {
    for (final record in projects) {
      if (record.project.id == id) return record;
    }
    return null;
  }

  Map<String, dynamic> projectJson(AcademicProject project) => {
    'id': project.id,
    'title': project.title,
    'description': project.description,
    'skillIds': project.skillIds,
    'conceptIds': project.conceptIds,
    'requirements': project.requirements,
    'deliverables': project.deliverables,
    'milestones': project.milestones,
    'acceptanceCriteria': project.acceptanceCriteria,
    'implementationTasks': project.implementationTasks,
    'testCases': project.testCases,
    'evidenceRequirements': project.evidenceRequirements,
    'recommendedToolCategories': project.recommendedToolCategories,
  };

  AcademicAssessmentRecord? assessmentById(String id) {
    for (final record in courses) {
      for (final unit in record.course.normalizedUnits) {
        for (final lesson in unit.lessons) {
          for (final assessment in lesson.assessments) {
            if (assessment.id == id) {
              return AcademicAssessmentRecord(
                assessment: assessment,
                course: record,
                lesson: lesson,
              );
            }
          }
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _fieldJson(AcademicField field) => {
    'id': field.id,
    'name': field.name,
    'universities': field.universities
        .map(
          (university) => {
            'id': university.id,
            'name': university.name,
            'colleges': university.colleges
                .map(
                  (college) => {
                    'id': college.id,
                    'name': college.name,
                    'specializations': college.specializations
                        .map(
                          (specialization) => _specializationJson(
                            fieldId: field.id,
                            universityId: university.id,
                            collegeId: college.id,
                            specialization: specialization,
                          ),
                        )
                        .toList(growable: false),
                  },
                )
                .toList(growable: false),
          },
        )
        .toList(growable: false),
  };

  Map<String, dynamic> _specializationJson({
    required String fieldId,
    required String universityId,
    required String collegeId,
    required AcademicSpecialization specialization,
  }) => {
    'id': specialization.id,
    'name': specialization.name,
    'fieldId': fieldId,
    'universityId': universityId,
    'collegeId': collegeId,
    'foundationCourseIds': specialization.foundationCourseIds,
    'years': specialization.years
        .map(
          (year) => {
            'number': year.number,
            'semesters': year.semesters
                .map(
                  (semester) => {
                    'number': semester.number,
                    'courseIds': semester.courses
                        .map((course) => course.id)
                        .toList(growable: false),
                  },
                )
                .toList(growable: false),
          },
        )
        .toList(growable: false),
  };

  Map<String, dynamic> _assessmentJson(LessonAssessment assessment) => {
    'id': assessment.id,
    'title': assessment.title,
    'questions': assessment.questions
        .map(
          (question) => {
            'id': question.id,
            'text': question.text,
            'options': question.options,
            'learningOutcomeIndexes': question.learningOutcomeIndexes,
            'conceptIds': question.conceptIds,
            'skillIds': question.skillIds,
            // correctIndex intentionally never leaves the backend.
          },
        )
        .toList(growable: false),
  };

  Map<String, dynamic>? _profileJson(AcademicCourseProfile? profile) {
    if (profile == null) return null;
    return {
      'credits': profile.credits,
      'contactHours': profile.contactHours,
      'practicalHours': profile.practicalHours,
      'complexity': profile.complexity.name,
    };
  }

  Map<String, dynamic> _provenanceJson(AcademicContentProvenance provenance) =>
      {
        'status': provenance.status.name,
        'author': provenance.author,
        'reviewer': provenance.reviewer,
        'version': provenance.version,
        'sourceReferences': provenance.sourceReferences
            .map(
              (reference) => {
                'id': reference.id,
                'title': reference.title,
                'publisher': reference.publisher,
                'kind': reference.kind,
                'url': reference.url,
                'version': reference.version,
              },
            )
            .toList(growable: false),
      };

  Map<String, dynamic> _skillJson(AcademicSkill skill) => {
    'id': skill.id,
    'name': skill.name,
    'learningOutcomeIds': skill.learningOutcomeIds,
    'evidenceRequirements': skill.evidenceRequirements,
  };

  Map<String, dynamic> _capabilityJson(AcademicCapability capability) => {
    'id': capability.id,
    'name': capability.name,
    'requiredSkillIds': capability.requiredSkillIds,
    'evidenceRequirements': capability.evidenceRequirements,
  };

  static List<AcademicCourseRecord> _buildCourses() {
    final records = <String, AcademicCourseRecord>{};
    for (final course in AcademicCatalog.foundationCourses) {
      records.putIfAbsent(
        course.id,
        () => AcademicCourseRecord(course: course),
      );
    }
    for (final field in AcademicCatalog.fields) {
      for (final university in field.universities) {
        for (final college in university.colleges) {
          for (final specialization in college.specializations) {
            for (final year in specialization.years) {
              for (final semester in year.semesters) {
                for (final course in semester.courses) {
                  records.putIfAbsent(
                    course.id,
                    () => AcademicCourseRecord(
                      course: course,
                      fieldId: field.id,
                      universityId: university.id,
                      collegeId: college.id,
                      specializationId: specialization.id,
                      year: year.number,
                      semester: semester.number,
                    ),
                  );
                }
              }
            }
          }
        }
      }
    }
    return records.values.toList(growable: false);
  }
}
