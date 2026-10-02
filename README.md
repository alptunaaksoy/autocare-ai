# AutoCare AI

A Flutter app for organizing vehicle maintenance and exploring AI-assisted automotive support, nearby services, and vehicle sound/fault workflows.

## Technology

- **Mobile app:** Flutter and Dart
- **Authentication and data:** Firebase Authentication and Cloud Firestore
- **AI features:** OpenAI API
- **Nearby services:** Google Places API
- **Device features:** location, image selection, audio recording, and local notifications

## Features

- Account registration and sign-in
- Vehicle profiles and maintenance records
- AI assistant and audio transcription workflows
- Nearby automotive service search
- Vehicle fault and engine-sound screens
- Local reminders and notifications

## Run locally

### Prerequisites

- Flutter SDK and an Android emulator or device
- A Firebase project with Authentication and Cloud Firestore configured
- OpenAI API access
- Google Places API access with an appropriately restricted key

### Configure credentials

Create a local credentials file from the example:

```powershell
Copy-Item secrets.example.json secrets.json
```

Fill in `OPENAI_API_KEY` and `GOOGLE_PLACES_API_KEY` in `secrets.json`. This file is ignored by Git. Create a Firebase project and enable Authentication and Cloud Firestore. Download `google-services.json` for Android to `android/app/`; use FlutterFire CLI (`dart pub global activate flutterfire_cli`, then `flutterfire configure`) to generate `lib/firebase_options.dart`. These project-specific client configuration files are ignored by Git; generate your own locally.

### Install and run

```powershell
flutter pub get
flutter run --dart-define-from-file=secrets.json
```

## Security

Never commit `secrets.json` or real API keys. Compile-time values in a mobile app can still be extracted from the built application. For production, route OpenAI requests through a backend and restrict the Google Places key to the required APIs and app identifiers. Protect user data with Firebase Authentication and Firestore security rules.

