# Installation Guide

## Prerequisites

| Requirement | Version | Download |
|---|---|---|
| Flutter SDK | 3.0+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.0+ (bundled with Flutter) | |
| Android SDK | API 21+ | Bundled with Android Studio |
| Java | 17+ | [adoptium.net](https://adoptium.net/) |
| Git | Latest | [git-scm.com](https://git-scm.com/) |
| IDE | Android Studio / VS Code | |

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/trackio.git
cd trackio
```

---

## Step 2: Install Dependencies

```bash
flutter pub get
```

This downloads all required packages defined in `pubspec.yaml`, including:
- `flutter_riverpod` — State management
- `go_router` — Routing
- `sqflite` — Local database
- `fl_chart` — Charts
- `google_generative_ai` — Gemini AI
- `google_mlkit_text_recognition` — OCR
- `image_picker` — Camera/gallery
- `intl` — Date and currency formatting
- And others...

---

## Step 3: Set Up Gemini API Key (Optional)

The AI Chat feature requires a Google Gemini API key:

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account
3. Click **Get API Key** and create a new key
4. Copy the key (starts with `AIza...`)
5. Open the app, navigate to the **AI Chat** tab, and enter your API key in the settings
6. The key is stored locally on your device via `shared_preferences`

> **Note:** OCR, transactions, and dashboard features work without an API key.

---

## Step 4: Run the Application

### On a Connected Device / Emulator

```bash
# Detect connected devices
flutter devices

# Run in debug mode
flutter run

# Run on a specific device
flutter run -d <device_id>
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing configuration)
flutter build apk --release
```

Output location:

| Build Type | Path |
|---|---|
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` |

---

## Step 5: Install on Android Device

### Via APK

1. Copy the APK file to your device
2. Enable **Install from unknown sources** in device settings
3. Open the APK file and follow installation prompts

### Via `flutter run`

1. Connect your device via USB with USB debugging enabled
2. Run `flutter run` — Flutter installs and launches the app automatically

---

## Troubleshooting

| Issue | Solution |
|---|---|
| `flutter: command not found` | Ensure Flutter SDK is in your system PATH |
| `Gradle build failed` | Run `flutter clean` then `flutter pub get` again |
| `No devices found` | Connect a device or start an emulator via Android Studio |
| `API key not working` | Verify the key is correct and Generative Language API is enabled in Google Cloud Console |
| `Database error` | Uninstall the app, run `flutter clean`, and rebuild |
