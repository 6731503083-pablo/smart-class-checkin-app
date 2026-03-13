# Smart Class Check-in and Learning Reflection App

## Project Description
This project is a Flutter MVP for class attendance and engagement verification.

It provides:
- Check-in (before class): GPS, timestamp, QR scan, previous topic, expected topic, mood (1-5)
- Finish Class (after class): GPS, timestamp, QR scan, learned today, class feedback
- Local persistence with SQLite and recent record history on Home screen

It also includes a Firebase Hosting deployment component in the hosting folder.

## Implementation Task Breakdown
Use this sequence to build and present quickly during the exam.

1. Requirement and data design
- Confirm mandatory fields and validation rules from PRD
- Finalize data models for check-in and finish-class

2. Project setup
- Add dependencies: sqflite, geolocator, mobile_scanner, uuid, firebase_core, cloud_firestore
- Create app structure: screens, services, models

3. Core features
- Build Home screen with navigation and recent records
- Build Check-in screen with GPS, QR scanner, and pre-class form
- Build Finish Class screen with GPS, QR scanner, and reflection form

4. Data persistence
- Create SQLite tables
- Save check-in and finish-class records
- Load recent records on Home screen

5. Firebase deployment component
- Build Flutter web output and deploy to Firebase Hosting

6. Final verification
- Check required field validation
- Check permission-denied behavior
- Check successful save and history update

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
- hosting/
	- index.html
- PRD_Smart_Class_CheckIn.md
- README.md
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
flutter build web
```

Why updates should appear without incognito:
- Firebase Hosting headers in firebase.json are configured to avoid stale caching of index.html, flutter_bootstrap.js, and flutter_service_worker.js.

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
2. flutter build web
3. firebase hosting deploy (live channel)

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
