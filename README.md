# MobyRead

MobyRead is a Flutter app to manage personal book lists. It supports scanning ISBNs with the device camera, fetching book metadata from Open Library, editing and adding books to "To read" and "Read" lists.

---

## Contents of this repository

- `android/`, `ios/` — platform projects
- `lib/` — Dart source code (UI, services, models, widgets)
- `pubspec.yaml` — dependencies and assets
- `assets/` — images and icons used by the app

Exclude generated folders (`build/`, `.dart_tool/`, `.gradle/`) when packaging source for submission.

---

## Prerequisites

- Flutter SDK (stable channel). Tested on recent stable releases; use a Flutter SDK >= 3.x.
- Android SDK + platform tools (for Android build and running on device).
- Java JDK (as required by Android toolchain).
- A physical Android device (recommended) or an AVD with webcam configured to test the camera scanner.
- If building on Windows and using plugins, enable Developer Mode to allow symlinks:
  - Run: `start ms-settings:developers` and enable Developer Mode.

---

## Dependencies

The app uses a few pub packages. After cloning the project, run:

```bash
flutter pub get
```

Notable packages:
- `mobile_scanner` — camera barcode scanning (requires camera permission).
- `http` — for Open Library requests.
- (Optional) `connectivity_plus` — connectivity checks.

If you encounter dependency resolution issues, run `flutter pub outdated` and follow prompts to align versions.

---

## Build & Run (development)

To run on a connected Android device:

1. Enable USB debugging on the device.
2. Connect device via USB and allow authorization.
3. From project root:

```bash
flutter pub get
flutter run -d <device-id>
```

To produce a debug APK:

```bash
flutter build apk --debug
# output: build/app/outputs/flutter-apk/app-debug.apk
```

To produce a release APK:

1. (Optional) Set up signing in `android/app/build.gradle` and provide a keystore.
2. Build release APK:

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Important: if you add native plugins, do a full rebuild (stop the running app and run `flutter run` again) to avoid `MissingPluginException`.

---

## What to include for the exam submission

For a "source buildable on Android" provide the project root with:
- `lib/`, `android/`, `pubspec.yaml`, `assets/`
- `pubspec.lock` (optional)
- README with build instructions (this file)

Do NOT include:
- `build/`, `.dart_tool/`, `.gradle/`, local keystores or any private credentials.

You may also provide:
- The compiled APK (`build/app/outputs/flutter-apk/app-release.apk` or `app-debug.apk`)
- A short script or note about required Flutter version.

To create a zip of the deliverable:

Windows PowerShell example:

```powershell
# from project root
Remove-Item -Recurse -Force build, .dart_tool -ErrorAction SilentlyContinue
Compress-Archive -Path . -DestinationPath ..\mobyread_submission.zip
```

---

## Permissions

The scanner requires camera permission:

- Android: ensure `android/app/src/main/AndroidManifest.xml` contains:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

- iOS: ensure `ios/Runner/Info.plist` contains:
```xml
<key>NSCameraUsageDescription</key>
<string>Usiamo la fotocamera per leggere il codice ISBN dei libri.</string>
```

At runtime the app will request camera permission on first use.

---

## How the app works (for the examiner)

Purpose
- Manage a small personal catalog of books: "Da leggere" (To read) and "Letti" (Read).
- Quickly add books by scanning ISBNs with the device camera.

Main screens
- Reading (Da leggere): list of books you plan to read.
- Home: recent events and quick actions (contains "Scanner ISBN" button).
- Finished (Letti): list of books you have read.

Navigation
- Bottom navigation switches between the three main screens.
- You can also swipe left/right between screens (Reading ↔ Home ↔ Finished).

ISBN scanner flow
1. Tap "Scanner ISBN" in Home (or use scanner entry).
2. Point camera at ISBN/EAN barcode.
3. When a barcode is detected:
   - The app validates the ISBN.
   - It queries Open Library for metadata.
   - If network error occurs, a dialog will prompt to check connection.
   - If the ISBN is not found, a "Not found" dialog appears.
   - If found, a dialog shows Title, Author and Genre.
     - Buttons:
       - "Annulla": closes dialog and resumes scanning.
       - "Modifica": opens an editor to change title/author/genre; after saving, returns to view dialog with updated data.
       - "Aggiungi": lets the user choose to add the book to "Da leggere" or "Letti"; after adding, a Snackbar confirms the action and the scanner resumes.
   - When multiple authors are returned by the API, only the first author is used (app supports a single author string).
   - Genre is taken from the first subject returned by the API (if available).

UX notes for testing
- Test the scanner on a real device for reliable camera input.
- If testing in emulator, configure the AVD camera to use a host webcam or show a barcode image on another screen and point the emulator camera to it.
- If you see `MissingPluginException` after adding packages, stop the app and run a full rebuild (`flutter clean` then `flutter run`).

---

## Troubleshooting

- Dependency conflicts:
  - Run `flutter pub get`; if version conflicts occur, consider adjusting package versions in `pubspec.yaml`.
- Plugins not found (MissingPluginException):
  - Stop the app and run `flutter run` again (full rebuild).
- APK install blocked on device:
  - Enable "Install via USB" or allow USB debugging prompts on the phone; if Play Protect blocks installation, disable it temporarily for testing.

---

## Contacts / notes

- The app uses Open Library (https://openlibrary.org) for metadata. Respect their usage policies and the service rate limits.
- If you need the app pre-signed for distribution, provide a signing key separately (do not include private keystore in the submission).

---

## Short checklist for the examiner (quick test plan)

1. Clone / unzip the provided project.
2. Run:
   ```bash
   flutter pub get
   flutter run -d <android-device>
   ```
3. On Home, tap "Scanner ISBN".
4. Scan a real ISBN barcode:
   - Verify metadata dialog appears with Title, Author, Genre.
   - Test "Modifica" (edit fields) and "Aggiungi" to both lists.
5. Verify lists (Reading / Finished) reflect additions.
6. Test behavior when device is offline: scanner should show an error prompting to check the connection.

---

Grazie — per qualsiasi dubbio su build o test, fornisco istruzioni aggiuntive su richiesta.
