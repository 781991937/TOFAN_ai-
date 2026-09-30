# TOFAN Academic Library Quality Gate

## Purpose

This gate is applied before a lesson is treated as teachable content. A lesson is not considered complete merely because a title and a paragraph exist.

## Required lesson chain

Every lesson must support:

1. Concept
2. Definition
3. Explanation
4. Key terms
5. Example
6. Application
7. Graduated practice
8. Assessment
9. Error analysis
10. Skill update
11. Project

The runtime learning lifecycle remains:

**Diagnostic -> Learning Plan -> Study -> Practice -> Assessment -> Analysis -> Skill Update -> Project**

## Academic coverage model

For the global computing library, TOFAN uses CS2023 as a reference framework for coverage rather than copying a university curriculum. CS2023 organizes computing knowledge into Knowledge Areas, Knowledge Units, Topics, and illustrative Learning Outcomes. The final framework identifies 17 Knowledge Areas.

Reference:
https://csed.acm.org/

The 17 areas are:

- Algorithmic Foundations
- Architecture and Organization
- Artificial Intelligence
- Data Management
- Foundations of Programming Languages
- Graphics and Interactive Techniques
- Human-Computer Interaction
- Mathematical and Statistical Foundations
- Networking and Communication
- Operating Systems
- Parallel and Distributed Computing
- Security
- Society, Ethics, and the Profession
- Software Development Fundamentals
- Software Engineering
- Specialized Platform Development
- Systems Fundamentals

## Content acceptance criteria

A lesson is accepted only when:

- Its concepts are accurate and appropriate to the course.
- Definitions precede dependent explanations.
- Terms are used consistently.
- Examples demonstrate the concept rather than merely restating it.
- Practice progresses from recognition to application and analysis.
- Assessment measures the stated learning outcomes.
- Assessment distractors represent plausible misconceptions rather than random wrong answers.
- Error analysis explains why an answer or approach fails.
- Skill update records an observable capability.
- The project requires transfer of the learned skill to a realistic task.
- The lesson does not introduce unexplained prerequisite concepts.
- The lesson does not duplicate another lesson's primary objective.
- The lesson is consistent with the unit and course scope.

## Coverage gate

Before expanding a specialization, review:

- Required knowledge areas.
- Required knowledge units.
- Topic coverage.
- Prerequisite relationships.
- Learning outcomes.
- Practice coverage.
- Assessment coverage.
- Project coverage.
- Cross-course duplication.
- Terminology consistency.

## Current implementation policy

Generated content is a scaffold only. A generated lesson must not be treated as equivalent to a fully reviewed academic lesson simply because all runtime fields are populated.

Deep content is added by domain-specific blueprints first. Remaining generic blueprints are progressively replaced as each knowledge area is reviewed.

This prevents the library from appearing complete while hiding shallow or duplicated instructional content.


## Executable instructional schema

The academic model now stores the instructional chain explicitly:

- `definition`: the primary definition that precedes dependent explanation.
- `applications`: concrete transfer contexts.
- `learningOutcomes`: observable outcomes.
- `keyTerms` and `examples`: terminology and worked context.
- `practices`: graduated learner tasks.
- `AssessmentQuestion.learningOutcomeIndexes`: outcome alignment.
- `AssessmentQuestion.conceptIds` and `skillIds`: assessment-to-knowledge/skill alignment.
- `errorAnalysisGuidance`: guidance for diagnosing learning errors.
- `skillEvidence`: observable evidence for skill acquisition.
- `AcademicProject.conceptIds` and `skillIds`: project transfer alignment.

The audit rejects published lessons that omit these instructional evidence links.

## Prerequisite integrity

Course prerequisites are treated as a directed graph. The audit checks:

1. Every referenced prerequisite course exists.
2. A course cannot depend on itself.
3. The prerequisite graph contains no cycles.

No prerequisite identifier is generated unless it refers to an actual course in the catalog.

## Global curriculum reference

TOFAN uses CS2023 as a coverage reference, not as a copied university curriculum. CS2023 identifies 17 knowledge areas and distinguishes knowledge areas from individual courses; this allows TOFAN to build a global foundational library while retaining its own course packaging and original instructional content.

Reference: https://csed.acm.org/


## Canonical knowledge-area layer

TOFAN now maintains a canonical 17-area knowledge model in
`lib/data/academic/academic_knowledge_area_catalog.dart`. Each area has
original TOFAN instructional units. Courses reference one or more area IDs,
which lets the library support coverage auditing and later knowledge-graph
retrieval without treating a knowledge area as a course.

The 17 identifiers are AI, AL, AR, DM, FPL, GIT, HCI, MSF, NC, OS, PDC, SEC,
SEP, SDF, SE, SPD, and SF. This set follows the CS2023 knowledge-area model. See https://csed.acm.org/knowledge-areas/ and the CS2023 final report.

TOFAN does not copy CS2023 course packages. CS2023 itself distinguishes
knowledge areas from courses and notes that a course can combine topics from
multiple knowledge areas; TOFAN uses that principle to keep its global library
modular.

## Security quality gate

The academic library is compartmentalized into explicit security domains. Every canonical
knowledge area must belong to exactly one domain. Access is deny-by-default and every
new capability requires an explicit policy rule. Learning agents must not receive
unrestricted database access or library administration. The security architecture is
part of the academic-library foundation, not an optional later feature.
