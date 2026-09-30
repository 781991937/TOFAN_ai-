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
