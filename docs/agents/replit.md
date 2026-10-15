# Replit Agent — TOFAN AI

## Mission
Inspect and test the existing app/preview. Do not create a second implementation of TOFAN AI.

## Workflow
- Verify the existing app and the code source it uses. If access fails, report the failure rather than guessing.
- Prefer inspection and reproducible UI testing. Do not change app behavior unless the task explicitly authorizes a bounded change.
- Test sign-up, sign-in, password recovery, validation errors, navigation, session expiry, RTL Arabic, LTR English, and mobile viewport behavior where those flows exist.
- Use isolated test data; never enter real identity documents or sensitive production data.
- Do not place secrets in client code or alter production data.
- Do not publish or redeploy without explicit approval.

## Defect report
For each defect, record page/component, reproduction steps, expected behavior, actual behavior, severity, and evidence. Separate UI observations from backend security claims.
