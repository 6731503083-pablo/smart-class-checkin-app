# Product Requirement Document (PRD)

## Product Name
Smart Class Check-in and Learning Reflection App

## Problem Statement
Universities need a lightweight method to verify student attendance and participation in each class session. Manual attendance cannot confirm physical presence or student engagement. The app solves this by combining GPS location, QR verification, and short reflection forms before and after class.

## Target Users
- Primary user: University students enrolled in a class
- Secondary user: Instructors who want check-in and reflection records

## Product Goals (MVP)
- Verify that a student is physically near the classroom during check-in and finish-class events
- Verify in-class participation by requiring a second QR scan and post-class reflection
- Store check-in and finish-class records reliably for later review

## Non-Goals (MVP)
- Complex analytics dashboard
- Multi-role admin portal
- Offline sync conflict resolution

## Feature List
1. Home Screen
- Start Check-in flow
- Start Finish Class flow
- View recent records summary

2. Check-in Screen (Before Class)
- Capture timestamp automatically
- Capture GPS coordinates (latitude, longitude)
- Scan class QR code
- Required inputs:
  - Previous class topic
  - Expected topic for today
  - Mood before class (1 to 5)
- Save record locally

3. Finish Class Screen (After Class)
- Capture timestamp automatically
- Capture GPS coordinates again
- Scan class QR code again
- Required inputs:
  - What I learned today (short text)
  - Class or instructor feedback
- Save record locally

4. Data Persistence
- Store records in SQLite on device (MVP requirement)
- Keep a local list/history for proof of save

5. Firebase Component (for integration and deployment requirement)
- Provide a Firebase-hosted web page (or Flutter web build) as deployment artifact
- Optional: send selected records to Firebase Firestore when configured

## User Flow
1. Student opens app and lands on Home Screen.
2. Student taps Check-in.
3. App requests location permission if needed.
4. Student scans class QR.
5. Student completes check-in form and submits.
6. App validates required fields and saves data.
7. At class end, student taps Finish Class.
8. Student scans QR again, app captures location and timestamp.
9. Student submits learning reflection and feedback.
10. App saves finish-class record and confirms success.

## Functional Requirements
- App must provide 3 screens: Home, Check-in, Finish Class.
- App must capture GPS coordinates on both check-in and finish-class.
- App must support QR scanning on both flows.
- App must validate required form inputs before save.
- App must persist data locally using SQLite.

## Data Fields
### Check-in Record
- id (string/uuid)
- createdAt (ISO timestamp)
- qrCodeValue (string)
- latitude (double)
- longitude (double)
- previousTopic (string)
- expectedTopicToday (string)
- moodBeforeClass (int: 1-5)

### Finish-Class Record
- id (string/uuid)
- createdAt (ISO timestamp)
- qrCodeValue (string)
- latitude (double)
- longitude (double)
- learnedToday (string)
- classFeedback (string)

## Validation Rules
- All text fields are required
- Mood must be between 1 and 5
- GPS must be captured before submit
- QR value must not be empty

## Tech Stack
- Frontend: Flutter (Dart)
- Local storage: SQLite (sqflite)
- Location: geolocator
- QR scanning: mobile_scanner
- Firebase: firebase_core, cloud_firestore (optional sync), Firebase Hosting for deployment
- State handling: setState (MVP simplicity)

## Success Criteria
- User can complete check-in and finish-class flows without crash
- GPS + QR + form data are saved locally
- Source code is available in GitHub
- At least one component is deployed on Firebase Hosting with accessible URL

## Risks and Mitigation
- GPS permission denied: show clear prompt and retry guidance
- Camera permission denied: show scanner permission guidance
- Firebase config missing: keep local features fully functional and document setup in README