# Bible Pronounce (Flutter)

A beginner-friendly, cross-platform Flutter app (iOS + Android) for learning how to pronounce difficult Bible names.

## Features

- Search bar + list of Bible words on the home screen
- Local dataset with **50+ difficult Bible names**
- Detail screen showing:
  - word
  - phonetic spelling
  - **real Google Cloud Text-to-Speech playback**
  - **voice recording for pronunciation practice**
- Verse helper to paste Bible verses and **highlight difficult words**
- Favorites support (persisted locally) using `shared_preferences`
- Material 3 UI with improved cards, gradients, and spacing

---

## Project Structure

```text
lib/
  data/
    bible_words_data.dart      # Local words dataset (50+)
  models/
    bible_word.dart            # BibleWord model
  screens/
    home_screen.dart           # Search + verse highlighting UI
    detail_screen.dart         # Word details + TTS + recording controls
  services/
    audio_service.dart         # Audio player wrapper
    google_tts_service.dart    # Google Cloud TTS integration
    favorites_service.dart     # Saved favorites persistence
  main.dart                    # App entry + theme config
```

---

## Prerequisites

1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Verify setup:

```bash
flutter doctor
```

---

## Run Locally

From the project root:

```bash
flutter pub get
flutter run --dart-define=GOOGLE_TTS_API_KEY=YOUR_GOOGLE_CLOUD_API_KEY
```

> If `GOOGLE_TTS_API_KEY` is not supplied, the app still runs but TTS playback is disabled with an in-app warning.

### Run on iOS Simulator

```bash
open -a Simulator
flutter run --dart-define=GOOGLE_TTS_API_KEY=YOUR_GOOGLE_CLOUD_API_KEY
```

### Run on Android Emulator

```bash
flutter emulators --launch <emulator_id>
flutter run --dart-define=GOOGLE_TTS_API_KEY=YOUR_GOOGLE_CLOUD_API_KEY
```
