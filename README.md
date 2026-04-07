# Bible Pronounce (Flutter)

A beginner-friendly, cross-platform Flutter app (iOS + Android) for learning how to pronounce difficult Bible names.

## Features

- Search bar + list of Bible words on the home screen
- Local dataset with **50+ difficult Bible names**
- Detail screen showing:
  - word
  - phonetic spelling
  - pronunciation audio button
- Audio playback with play/pause using `just_audio`
- Favorites support (persisted locally) using `shared_preferences`
- Material 3 clean UI + automatic dark mode support

---

## Project Structure

```text
lib/
  data/
    bible_words_data.dart      # Local words dataset (50+)
  models/
    bible_word.dart            # BibleWord model
  screens/
    home_screen.dart           # Search + list UI
    detail_screen.dart         # Word details + audio controls
  services/
    audio_service.dart         # Audio player wrapper
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
flutter run
```

### Run on iOS Simulator

```bash
open -a Simulator
flutter run
```

### Run on Android Emulator

```bash
flutter emulators --launch <emulator_id>
flutter run
```

---

## Notes for Beginners

- Audio URLs are placeholders (`https://example.com/...`).
- Replace them with real MP3 links (or local assets) to hear actual pronunciation.
- Favorites are saved on-device and restored at app startup.

---

## Next Improvements (Optional)

- Add tabs: **All Words** and **Favorites**
- Download/caching of audio files
- Add offline audio assets
- Add category filters (Old Testament / New Testament)
- Add “Word of the day”
