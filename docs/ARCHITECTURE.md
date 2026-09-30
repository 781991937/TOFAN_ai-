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
The AI Core provides one application-level interface. Provider adapters may include OpenAI, Gemini and future providers.
The application must not expose provider secrets to ordinary students.

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

## Academic hierarchy
University → College/Center → Specialization → Year → Semester → Course → Lesson/File/Assessment/Project

The catalog is global. Sana'a University can be reference data, not a platform limitation.

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
