# TOFAN Academic Project-Build Model

## Purpose

The Global Academic Library is the canonical knowledge foundation of TOFAN.
Courses and lessons are not treated only as subjects to memorize. They expose
structured evidence for determining which knowledge, skills, concepts, and
project exercises can contribute to a build.

This model is derived from the existing catalog. It does not invent a new
curriculum and it does not replace the existing project engine.

## Build path

User requirement -> project capability retrieval -> relevant courses ->
relevant lessons -> knowledge units -> concepts and skills -> practices and
assessments -> project evidence -> prerequisite/gap analysis -> build plan ->
implementation -> tests -> evaluation -> experience memory.

A matching course does not mean that the library has enough knowledge to build
an entire production system. Cross-disciplinary systems should combine several
capability groups and the agent must report remaining gaps.

## Current implementation

AcademicProjectCapabilityEngine derives project-oriented capability records from
AcademicCatalog. Each record carries the specialization, course, CS2023
knowledge areas and units, lesson IDs, concepts, skills, and project evidence.

The engine exposes capabilitiesFor(request), canStartBuild(request), and
missingEvidence(request).

This is the library-side foundation for the later Abqari execution layer.

## Current limitation

The engine is a deterministic lexical capability index. It is not semantic or
vector retrieval, and it does not claim that every generated course is ready
for every type of real-world project.

The catalog still contains generated global courses whose content is broader
than a final domain-specific curriculum. Those courses must be audited and
deepened before being treated as authoritative preparation for every project.

## Academic design basis

CS2023 separates a knowledge model from a competency model and treats them as
complementary. It also describes course and curricular packaging rather than
requiring one fixed course structure. TOFAN therefore keeps the knowledge model
canonical while deriving project and competency evidence from it.
