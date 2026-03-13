# Smart Class Check-in and Learning Reflection App

## Midterm Submission Package
Required submission items are present in this repository:

1. PRD.md
	- File: PRD.md
2. Source Code (GitHub)
	- Repo URL: https://github.com/6731503083-pablo/smart-class-checkin-app
	- Instructor access: add vittayasak@mfu.ac.th to the repository
3. Firebase Host Deployment URL
	- https://smart-class-checkin.web.app
4. README.md
	- File: README.md (this file)
5. AI Usage Report
	- File: AI_USAGE_REPORT.md

## Rubric Alignment Snapshot
1. Requirement Analysis & Product Spec
	- Covered in PRD.md with problem, features, flow, fields, and validation.
2. System Design
	- Clear user flow and data model in PRD.md and app structure in source.
3. Flutter Implementation
	- Home, Check-in, Finish Class with navigation, forms, QR, GPS, and save.
4. Firebase Integration
	- Firebase hosting and optional Firebase setup documented.
5. Deployment
	- Public URL active and accessible via Firebase Hosting.
6. Code Quality
	- Refactored and organized files; analyzer/build checks pass.
7. AI Usage & Engineering Judgment
	- Documented in AI_USAGE_REPORT.md with manual decisions and validation steps.

## Exam Rubric Scope (Strict)
This repository is intentionally limited to the MVP requirements defined in the exam PRD/rubric.

Included scope only:
- 3 screens: Home, Check-in (Before Class), Finish Class (After Class)
- GPS capture on both flows
- QR scan on both flows
- Required form validation
- Local persistence with SQLite
- Firebase Hosting deployment artifact

Not included by design (out of rubric):
- Advanced analytics dashboards
- Multi-role admin portal
- Complex sync/conflict workflows

Implementation policy for this repo:
- Do not introduce features outside the exam rubric.
- Changes must preserve required fields and validation rules from PRD.
- Keep architecture simple and explainable for exam demo.

## Project Description
Flutter MVP for class attendance and learning reflection verification.

Implemented:
- Check-in (before class): timestamp, GPS, QR scan, previous topic, expected topic, mood (1-5)
- Finish Class (after class): timestamp, GPS, QR scan, learned today, class feedback
- Local history on Home screen
- Permission handling UX for location/camera
- Human-readable location text fallback
- 12-hour time display (AM/PM)

## Folder Structure
.
- lib/
	- main.dart
	- models/
		- check_in_record.dart
		- finish_class_record.dart
	- screens/
		- home_screen.dart
		- check_in_screen.dart
		- finish_class_screen.dart
	- services/
		- database_service.dart
		- location_service.dart
	- widgets/
		- animated_entry.dart
- web/
	- index.html
- PRD.md
- README.md
- AI_USAGE_REPORT.md
- pubspec.yaml
- firebase.json
- .firebaserc

## Setup Instructions
Prerequisites:
- Flutter SDK installed
- Android Studio or VS Code Flutter extension
- Firebase CLI installed (for deployment)

Install dependencies:

```bash
flutter pub get
```

Run on device/emulator:

```bash
flutter run
```

Run web locally:

```bash
flutter run -d chrome
```

## Rubric Verification Checklist
Use this quick checklist before submission/demo.

1. Home screen opens and navigation to both flows works.
2. Check-in requires GPS + QR + all required fields.
3. Finish Class requires GPS + QR + all required fields.
4. Mood in Check-in remains in range 1-5.
5. Records are saved locally and appear in recent history.
6. Permission denied states show guidance actions.
7. Web build deploys to Firebase Hosting successfully.

## Firebase Configuration Notes
This repository is local-first and works even if Firebase is not configured.

If you want full Firebase integration:
1. Create a Firebase project.
2. Replace default project id in .firebaserc.
3. Configure platform files (Android/iOS/Web) using FlutterFire tools if needed.
4. Deploy hosting component:

```bash
npx --yes firebase-tools login
npx --yes firebase-tools use --add
npx --yes firebase-tools deploy --only hosting
```

## Deployment Artifact
The deployable component is:
- Flutter Web build output in build/web

Build web before deploy:

```bash
flutter build web --pwa-strategy=none
```

Why updates should appear without incognito:
- Firebase Hosting headers are configured to avoid stale caching of web entry files.
- Startup cache reset logic in web/index.html clears old service worker/caches from earlier builds.

After deploy, add your public URL here:
- Firebase URL: https://smart-class-checkin.web.app

## Auto Deploy from GitHub Push
This repository is configured with GitHub Actions to auto deploy to Firebase Hosting when code is pushed to main.

Workflow file:
- .github/workflows/firebase-hosting.yml

One-time setup required in GitHub:
1. Go to Firebase Console > Project Settings > Service accounts.
2. Generate a new private key (JSON) for Firebase Admin SDK.
3. In GitHub repo settings, open Secrets and variables > Actions.
4. Create a repository secret named FIREBASE_SERVICE_ACCOUNT_SMART_CLASS_CHECKIN.
5. Paste the full JSON content as the secret value.

After this setup, every push to main triggers:
1. flutter pub get
2. flutter build web --pwa-strategy=none
3. firebase hosting deploy (live channel)

## Stability Notes (Within Rubric)
- Local-first behavior remains primary requirement.
- Firebase/Firestore sync is optional and does not block rubric completion.
- If external reverse-geocoding service is unavailable, app still stores accurate GPS coordinates and uses a friendly fallback location label.

## AI Usage Report (Short)
AI tools used:
- GitHub Copilot (GPT-5.3-Codex)

AI-assisted outputs:
- Flutter project scaffolding structure
- SQLite data service template
- QR scan and location capture flow structure
- README and deployment checklist draft

Manual work and engineering decisions:
- Adjusted validations to match PRD rules
- Implemented record models and table fields explicitly
- Implemented screen-level UX flow and save behavior
- Organized files for maintainability and exam explainability
