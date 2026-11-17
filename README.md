# SAMPTS

Student–Advisor Meeting and Project Tracking System built with Flutter, Firebase Authentication, and Firebase Realtime Database.

## Implemented

- Email/password registration and sign-in, password reset, and Google sign-in.
- Authentication state routing, sign-out, and retryable profile provisioning.
- New accounts receive a student profile. Existing roles are preserved; advisor access must be assigned by an administrator.
- User, Student, Advisor, Project, and Meeting models.
- Typed Realtime Database create/read/update/delete services and live filtered streams. Meeting times use UTC epoch milliseconds.
- Participant access rules and emulator tests. Meeting/project workflow screens are not implemented yet.

## Run Android

```sh
flutter pub get
flutter run
```

Firebase project: `sampts-ea8c4`.
Android application ID: `com.samparts.samp_ts`.
Database: `https://sampts-ea8c4-default-rtdb.firebaseio.com`.

Android configuration comes from `android/app/google-services.json` and matching `lib/firebase_options.dart`. Build tooling uses Kotlin 2.4.0, NDK 27.0.12077973, and minimum Android API 24.

### Google sign-in setup

Enable Google and Email/Password in Firebase Authentication. Register the signing certificate fingerprints in Firebase Console → Project settings → Android app → Add fingerprint, then download a fresh `google-services.json` if Firebase changes the OAuth configuration.

For this computer's current debug keystore:

```text
SHA-1:   80:44:BE:12:CC:05:D7:50:22:CA:45:5B:E7:F6:1D:12:ED:42:BF:1C
SHA-256: 9D:62:78:B7:4C:3C:11:65:8C:87:7F:94:72:6C:F2:2A:68:E4:BA:00:A3:27:76:60:16:77:B2:29:2B:14:74:FB
```

Other developers and release signing use different certificates. Register those fingerprints separately. The supplied config contains a web OAuth client; the SDK uses it as the server client ID. Successful sign-in must still be checked on an Android device with Google Play services. No live accounts are created by automated tests.

## Realtime Database rules

Sign into a Google account that can access SAMPTS, then deploy:

```sh
firebase login:add
firebase login:use YOUR_EMAIL
firebase deploy --only database --project sampts-ea8c4
```

The previously signed-in CLI account cannot access SAMPTS; these rules have not been deployed. Until deployed, live behavior depends on the rules currently in Firebase Console.

Rules allow users to provision/update their own profile, prevent self-assignment of advisor roles, restrict projects/meetings to their participants, and restrict milestone/approval changes to the assigned advisor. Student/advisor IDs are Authentication UIDs. Administrators assign `users/{uid}/role = advisor` and `students/{studentUid}/advisorId` in the console or a trusted server. A student can create their own `students/{uid}` record with `userId` and `studentNumber`; assignments cannot be changed by the student.

Lists must be queried by participant, since database rules do not filter results:

```dart
final db = DatabaseService(FirebaseDatabase.instance);
final meetings = db.meetings.watch(field: 'studentId', isEqualTo: uid);
final id = db.meetings.newId();
await db.meetings.create(Meeting(
  id: id, studentId: uid, advisorId: assignedAdvisorUid,
  scheduledAt: DateTime.now().toUtc(), durationMinutes: 30,
  status: MeetingStatus.pending, notes: '',
));
await db.meetings.update(id, {'status': MeetingStatus.cancelled.name});
```

Import `firebase_database`, `lib/services/database_service.dart`, and the relevant model in callers. Create rejects existing IDs; update rejects missing records. Delete removes a single record, not related data or Authentication accounts. Server rules may deny operations that a user's role cannot perform.

This code uses Realtime Database, not Firestore. Existing Firestore records, if any, are not migrated automatically.

## Checks

```sh
flutter analyze
flutter test
npm ci
npm run test:rules
flutter build apk --debug
```

Rules tests require Node.js, Java 21+ for the current Firebase CLI, and Firebase CLI; they use a local demo project and never modify the live database.

On this machine, the installed database emulator v4.11.2 also works directly with Java 17. In one terminal run:

```sh
java -jar ~/.cache/firebase/emulators/firebase-database-emulator-v4.11.2.jar --host 127.0.0.1 --port 9000
```

Then run `node --test test/rules/database.test.mjs` in another terminal. Stop the emulator with Ctrl+C afterward.

## Other platforms

Android is configured. To register iOS and web apps, use an account with project access and run:

```sh
flutterfire configure --project=sampts-ea8c4 --platforms=android,ios,web
```

Additional Google provider platform setup may be required. See the official Firebase [authentication](https://firebase.google.com/docs/auth/flutter/federated-auth) and [Realtime Database](https://firebase.google.com/docs/database/flutter/read-and-write) guides.

Never commit passwords, access tokens, service-account keys, or private signing keys. Firebase client app configuration identifies the project and is not a server credential.
