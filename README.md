# live-score-app-anupom

A Flutter app for live match scores. Home and match details use Cloud Firestore snapshot streams, so scores change without a manual refresh. Score admin can create a match and update scores and status.

## Firebase project

- Project ID: `live-score-app-anupom`
- Firestore: default database, Mumbai (`asia-south1`), Standard edition
- Registered apps: Android (`com.example.live_score_app`) and Web
- Platform configuration: `lib/firebase_options.dart`; Android SDK configuration: `android/app/google-services.json`

The app is configured for **Android and Web**. The other generated Flutter platforms need their own Firebase app registrations before use.

## Run

```powershell
flutter pub get
flutter run
```

Choose an Android device or a web browser when prompted. For a web release build:

```powershell
flutter build web
```

If Windows application control blocks Flutter's `font-subset.exe`, run `flutter build web --no-tree-shake-icons`.

## Firestore data

Use **Score admin** in the home toolbar to add the first match. This creates a document in the `matches` collection. No local sample scores are used.

| Field | Type | Example |
| --- | --- | --- |
| `teamA` | string | `Bangladesh` |
| `teamB` | string | `India` |
| `scoreA` | integer | `125` |
| `scoreB` | integer | `124` |
| `status` | string | `Live` (`Upcoming`, `Live`, `Finished`) |
| `matchDate` | timestamp | Date and time of the match |
| `venue` | string | `Mirpur Stadium` |
| `details` | string | Optional match information |

Home supports team and venue search, plus status filters. To check live updates, leave home open and change a score from Score admin or Firebase Console. Home and details should update automatically.

## Demo access rules

The deployed `firestore.rules` allows public reads of `matches` and public creation or score updates **without an expiry date**. It checks field types and restricts updates to score and status. Other collections and deletes are denied. This is only for the assignment demo: there is no admin sign-in, so anyone with the app can update scores at any time. Add authentication and private write rules before using real match data or publishing broadly.

After editing the rules, publish them with:

```powershell
firebase deploy --only firestore:rules --project live-score-app-anupom
```
