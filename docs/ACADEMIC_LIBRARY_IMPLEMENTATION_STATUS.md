# TOFAN Academic Library — Implementation Status

## Current architecture

The Global Academic Library is the canonical knowledge foundation of TOFAN SMART ACADEMY. TOFAN ABQARI consumes this library as its knowledge and execution substrate; it is not a replacement for the library.

## Verified foundations

- 17 CS2023-aligned knowledge areas are represented.
- Knowledge units are modeled separately from courses.
- Courses reference knowledge areas and knowledge units.
- Lessons carry learning outcomes, concepts, skills, practice, assessment and project evidence.
- A library structural/instructional audit exists.
- Library security domains and deny-by-default access rules exist.
- A canonical external-source registry now exists.
- Course and lesson provenance/publication metadata are now part of the domain model.
- Course curriculum profiles now have explicit fields for credits, contact hours, practical hours and complexity.

## Current gaps before the library is production-ready

- Existing courses have not yet been assigned reviewed credit/contact-hour profiles.
- Existing lessons are still draft content and do not yet carry source references individually.
- Prerequisite sequencing is present as a field and audited, but the global prerequisite graph needs systematic completion.
- The current in-code catalog is still a seed representation; durable database-backed library storage is later work.
- Topic-level provenance and reference mapping must be completed before content is marked published.
- Generic/generated lesson scaffolds must continue to be replaced or validated by domain-specific content.

## Source policy

TOFAN uses external curriculum frameworks to define coverage and structure, not as copied university courseware. CS2023 is the primary Computer Science knowledge-model reference; CC2020 provides the broader computing-discipline context; cybersecurity uses dedicated cybersecurity curricular guidance such as CSEC2017. The actual TOFAN lesson content remains original and must carry provenance before publication.

## Readiness rule

`AcademicLibraryAudit.isHealthy` means the structural/instructional integrity checks pass.

`AcademicLibraryAudit.isCurriculumReady` additionally requires all course weight/delivery metadata and lesson/course provenance gaps to be resolved.

Until the latter is true, the library must be treated as a controlled development library, not a fully validated production curriculum.

