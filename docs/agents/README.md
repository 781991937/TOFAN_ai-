# TOFAN AI — Agent Operating Model

Project repository: https://github.com/781991937/TOFAN_ai-
Primary branch: `main`
Supabase project ref: `akzwfvtgdioghvwviczh`

## Governance
- Preserve the existing project. Do not rebuild it or create a parallel implementation.
- Follow `KEEP → EXTEND → CONNECT → REFACTOR → CREATE`.
- GitHub is the source of truth for code and code changes; Supabase is the source of truth for live database state.
- Read existing project documentation before implementation: `ROADMAP.md`, Master Execution Matrix, Technical Implementation Model, and PHASE 3 IMPLEMENTATION INSTRUCTIONS. If missing, report that; do not invent it.
- Do not create parallel replacements named `AcademicCatalog2`, `ProjectEngine2`, `ABQARI2`, `AI_Core2`, `StudentModel2`, or `Agent2`.
- Never trust owner roles, owner IDs, or authorization claims supplied by the client. Never use email alone as proof of ownership. Never ship `service_role` or server secrets in Flutter.
- No production migration, deployment, secret change, owner creation/approval, or PR merge without explicit approval.
- Every agent must distinguish completed-and-verified, implemented-but-untested, in progress, planned, blocked, and approval-required work.
- Do not claim work, tests, or deployments that were not actually performed.

## Tool ownership
- GitHub: code, branches, tests, CI, PRs.
- Supabase: live schema, migration ledger, RLS, grants, Auth configuration, advisors.
- Manus: independent audit and bounded implementation only when access permits.
- Figma: existing approved design and design-system continuity.
- Replit: read-only app inspection and UI reproduction tests unless explicitly authorized otherwise.
- PrivacyHawk: privacy-risk recommendations only when its capabilities apply.
- Ads Manager: advertising only; not application engineering.
- Rhythm AI Personality Tuner: optional conversational-style tuning; not a code or security dependency.

## Required report
1. Scope and timestamp.
2. Evidence checked.
3. Confirmed findings.
4. Changes actually made and links.
5. Tests run and exact outcomes.
6. Remaining risks and blockers.
7. Next action and whether approval is required.
