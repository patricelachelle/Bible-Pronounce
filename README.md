# Bible Pronounce (Flutter)

An (iOS + Android) app for learning to pronounce difficult Bible names with **real Google Cloud Text-to-Speech (TTS)**.

## Features

- Search + browse 50+ difficult Bible names
- Detail screen with:
  - Word and phonetic spelling
  - Real Google Cloud TTS playback (normal + slow mode)
  - Practice recording and replay
- Uses **phonetic text** for TTS requests to improve pronunciation accuracy
- Caches generated MP3 audio locally for instant/offline replay after first play
- Handles loading and error states in the UI
- Favorites support with local persistence (`shared_preferences`)

---

## Google Cloud TTS setup

1. Create/select a Google Cloud project in Google Cloud Console.
2. Enable **Cloud Text-to-Speech API**.
3. Create an API key (APIs & Services → Credentials).
4. Restrict the key for safety (recommended):
   - API restriction: Cloud Text-to-Speech API
   - App restriction: Android/iOS package restrictions where possible
5. Run the app with the API key via `--dart-define`:

```bash
flutter run --dart-define=GOOGLE_TTS_API_KEY=YOUR_GOOGLE_CLOUD_API_KEY
```

> If the key is missing, the app still runs and shows an in-app message when TTS is unavailable.

---

## Project Structure

```text
lib/
  data/
    bible_words_data.dart      # Local words dataset
  models/
    bible_word.dart            # BibleWord model (word + phonetic)
  screens/
    home_screen.dart           # Search + verse highlighting UI
    detail_screen.dart         # TTS controls + recording controls
  services/
    tts_service.dart           # Google TTS request + cache + playback
    audio_service.dart         # Local file playback for practice recordings
    favorites_service.dart     # Saved favorites persistence
  main.dart                    # App entry + theme config
```

---

## Run locally

```bash
flutter pub get
flutter run --dart-define=GOOGLE_TTS_API_KEY=YOUR_GOOGLE_CLOUD_API_KEY
```
