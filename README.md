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
firebase login
firebase use --add
firebase deploy --only hosting
```

## Deployment Artifact
The deployable component is:
- Flutter Web build output in build/web

Build web before deploy:

```bash
flutter build web
```

After deploy, add your public URL here:
- Firebase URL: <YOUR_FIREBASE_HOSTING_URL>

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
