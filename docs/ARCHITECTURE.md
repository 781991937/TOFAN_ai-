# TOFAN AI STUDENT — Architecture v1

## Product core
The product has two participants: Human Student and Smart Student (TOFAN AI Student).

The smart student uses the academic profile, knowledge state, skills, progress, assessments and projects to assist the human student through bounded AI agents.

## Main domains
- Identity & onboarding
- Academic catalog
- Student profile
- Smart-student profile
- Courses and lessons
- Academic files
- Learning sessions
- Assessments and results
- Knowledge / skills / capabilities
- Projects
- AI Core
- AI Agents
- Notifications
- Subscription
- Certificates
- Administration

## Client layers
- presentation/: screens and reusable UI
- application/: state and use cases
- domain/: entities and contracts
- data/: repositories and API/local data sources
- core/: configuration, errors, networking, localization and shared utilities
- ai/: AI Core contracts and provider adapters

Existing code is migrated incrementally. Do not rewrite working functionality only for directory aesthetics.

## AI Core
The AI Core provides one application-level interface through `lib/ai/ai_core.dart`.
The Flutter client depends on this contract rather than a provider-specific SDK.
Provider adapters may include OpenAI, Gemini and future providers, but credentials and network calls belong behind the backend AI gateway.
The current client foundation includes a safe unconfigured implementation; it does not fabricate AI answers or expose provider secrets.

## Agent model
Agents are specialized workers, not independent uncontrolled chatbots.
- Main Manager
- Academic Tutor
- Assessment Agent
- Knowledge Agent
- Skills Agent
- Project Agent
- File/Document Agent
- Progress Analyst
- Translation/Terminology Agent

The Main Manager coordinates bounded agent actions and records important events.

## Global Academic Library — approved structure
The academic library is a global, multi-disciplinary curriculum system. It is not limited to one university. Its approved structural hierarchy is:

**Academic Field → University → College/Center → Specialization → Year (1–4) → Semester (1–2) → Course → Unit → Lesson → Practice → Assessment → Analysis → Skill Update → Project**

Structural rules:
- The library may contain multiple academic fields and computing disciplines.
- Each specialization is organized across four academic years, with two semesters per year.
- Courses contain ordered units and lessons; lessons are the executable learning unit.
- Each lesson follows the approved learning lifecycle: Study → Practice → Assessment → Analysis → Skill Update → Project.
- University and college names are organizational/reference data and must not constrain the global scope of TOFAN.
- Academic content must be original TOFAN content grounded in recognized global curriculum knowledge; external frameworks guide coverage but are not copied as a university curriculum.
- The catalog is expanded by completing the structure and content systematically, not by creating parallel or duplicate catalogs.

Sana'a University remains valid as initial reference data, not as a platform limitation.

## Student lifecycle
Onboarding → Academic Profile → Diagnostic → Learning Plan → Study → Practice → Assessment → Analysis → Skill Update → Project

## Security
- server-side secrets
- authenticated API
- role-based authorization
- secure local storage for non-server secrets/session material
- audit events for privileged actions
- no hard-coded production API keys

## Implementation phases
1. Product shell
2. Academic core
3. Student intelligence
4. AI Core and agents
5. Learning and assessment engine
6. Projects and services
7. Production hardening
