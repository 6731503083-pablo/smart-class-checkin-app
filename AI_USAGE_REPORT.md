# AI Usage Report

## Tool Used
- GitHub Copilot (GPT-5.3-Codex)

## Where AI Was Used
- Initial Flutter project scaffolding and file organization guidance.
- Drafting and iterating SQLite data service and model wiring.
- Structuring check-in/finish-class screen workflows.
- Drafting documentation sections (README, submission checklist language).
- Refactoring for readability without changing rubric-required behavior.

## What Was Implemented Manually (Engineering Judgment)
- Verified and enforced rubric constraints (3 screens, GPS, QR, validation, SQLite, deployment).
- Kept MVP scope strict; avoided out-of-rubric features.
- Validated permissions and fallback UX behavior for camera/location.
- Adjusted data fields and validation to match PRD exactly.
- Verified deploy behavior and cache update reliability for web hosting.
- Ran analyze/build/deploy checks and fixed issues found during validation.

## Validation and Testing Approach
- `flutter analyze` to catch code issues after changes.
- `flutter build web --pwa-strategy=none` to confirm deployable artifact.
- Firebase Hosting deploy validation at:
  - https://smart-class-checkin.web.app
- Manual scenario checks:
  - Check-in requires GPS + QR + required fields.
  - Finish Class requires GPS + QR + required fields.
  - Records appear in local recent history.

## Understanding of Generated Code
- I can explain all key flows:
  - How GPS/QR is captured and validated before submit.
  - How SQLite persistence and recent record aggregation work.
  - How permission-denied states are surfaced to users.
  - How deployment is configured and triggered.

## AI Usage Boundaries
- AI suggestions were treated as drafts.
- Final decisions, scope control, and bug fixes were manually reviewed and applied to meet exam requirements.