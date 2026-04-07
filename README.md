# Bible Pronounce (Flutter)

A beginner-friendly iOS + Android app for learning to pronounce difficult Bible names with **Google Cloud Text-to-Speech (TTS)**.

## UX + Engagement Features

- **Favorites system**
  - Save words with a heart icon
  - Dedicated **Favorites** screen
  - Local persistence with `shared_preferences`
- **Categories + filtering**
  - Grouped by **People**, **Places**, and **Books of the Bible**
  - Quick category filter chips
- **Practice mode**
  - One word at a time
  - Tap to play pronunciation
  - Tap **Next** to move forward
  - Optional pronunciation quiz (“Which is correct?”)
- **Search improvements**
  - Instant filtering while typing
- **UI polish**
  - Navigation icons
  - Better spacing/typography
  - Subtle animations (switchers/scales)
- **Dark mode support**
  - Light + dark themes with consistent Material 3 color usage

---

## Project Structure (Clean and Simple)

```text
lib/
  data/
    bible_words_data.dart      # Local words dataset + category labels
  models/
    bible_word.dart            # BibleWord model + BibleWordCategory enum
  screens/
    home_screen.dart           # App shell with bottom navigation
    word_library_screen.dart   # Search + category filters + word list
    favorites_screen.dart      # Saved words list
    practice_screen.dart       # One-by-one practice + optional quiz
    detail_screen.dart         # Pronunciation playback + recording + favorite toggle
  services/
    word_repository.dart       # Filtering/query logic (repository layer)
    tts_service.dart           # Google TTS request + cache + playback
    audio_service.dart         # Local file playback for practice recordings
    favorites_service.dart     # Saved favorites persistence + UI notifier
  main.dart                    # App entry + theme config
```

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

## Run locally

```bash
flutter pub get
flutter run --dart-define=GOOGLE_TTS_API_KEY=YOUR_GOOGLE_CLOUD_API_KEY
```
