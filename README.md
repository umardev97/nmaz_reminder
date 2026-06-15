# nmaz_reminder

A polished Flutter application for prayer reminders, daily prayer tracking,
personal reflection, and family accountability.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Setup (Prayer & Daily Family Tracking App)

Quick steps to configure and run locally:

1. Create a Firebase project and enable Authentication, Firestore, Cloud Messaging, and Storage.
2. Add Android and iOS apps in Firebase console and download `google-services.json` / `GoogleService-Info.plist` into `android/app/` and `ios/Runner/` respectively.
3. Deploy `firestore.rules` via Firebase CLI: `firebase deploy --only firestore:rules`.
4. Install packages:

```bash
flutter pub get
```

5. Run the app:

```bash
flutter run
```

The app includes branded onboarding, Firebase authentication, prayer tracking,
daily reflections, reminder settings, a member profile, and an admin dashboard.

## Admin Dashboard

An Admin role (user document field `role: admin`) can access the in-app Admin Dashboard to view all users and quick stats. Admins are routed to the admin dashboard automatically on sign-in.

## Theming & UI

The app uses a centralized theme in `lib/core/theme.dart`. Update colors and typography there to change the UI across the app.

## Testing

Run tests with:

```bash
flutter test
```

I added a basic unit test for deterministic notification IDs at `test/notification_ids_test.dart`.

