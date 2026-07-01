# 🔤 KidsPhonics — Flutter App
**Grade 1 Mobile Learning App | Phonics & Literacy**

---

## 📱 App Overview

KidsPhonics is a gamified Flutter mobile app designed for Grade 1 learners (ages 6–7).
It teaches letter sounds, rhyming words, and vocabulary through:
- Picture-based visual learning
- Voice assistance (Text-to-Speech)
- Interactive games with XP rewards
- Parental controls panel

---

## 🗂️ Project Structure

```
kidsphonics/
├── lib/
│   ├── main.dart                    ← App entry + Splash screen
│   ├── theme/
│   │   └── app_theme.dart           ← Colors, text styles, theme
│   ├── data/
│   │   └── letter_data.dart         ← All 26 letters, game data
│   ├── providers/
│   │   └── app_provider.dart        ← TTS, XP, progress state
│   ├── widgets/
│   │   └── shared_widgets.dart      ← Reusable UI components
│   └── screens/
│       ├── home_screen.dart         ← Home / Dashboard
│       ├── lessons_screen.dart      ← Lesson list
│       ├── letter_sounds_screen.dart← A–Z letter sounds + pictures
│       ├── games_screen.dart        ← Game Zone hub
│       ├── sound_match_screen.dart  ← Game 1: Sound Match
│       ├── memory_game_screen.dart  ← Game 2: Memory Flip
│       ├── phonics_quiz_screen.dart ← Game 3: Phonics Quiz
│       ├── word_builder_screen.dart ← Game 4: Word Builder
│       └── parent_screen.dart       ← Parent Panel
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml     ← Android permissions
├── pubspec.yaml                    ← Dependencies
└── README.md
```

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK ≥ 3.0.0 (https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)
- Java 17+

### 1. Clone / Create project

```bash
# If starting fresh:
flutter create kidsphonics
cd kidsphonics

# Then replace the lib/ folder and pubspec.yaml with the provided files
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add Google Fonts (auto via pub)

The app uses **Nunito** and **Fredoka One** from `google_fonts` package.
They download automatically — no manual font files needed.

### 4. Create asset folders

```bash
mkdir -p assets/images assets/audio
```

Add placeholder files (or real assets later):
```bash
touch assets/images/.gitkeep
touch assets/audio/.gitkeep
```

### 5. Run the app

```bash
# List connected devices
flutter devices

# Run on connected Android device
flutter run

# Run on specific device
flutter run -d <device_id>

# Build APK
flutter build apk --release
```

---

## 📦 Dependencies Used

| Package | Version | Purpose |
|---|---|---|
| `flutter_tts` | ^4.0.2 | Text-to-speech voice assistance |
| `shared_preferences` | ^2.2.2 | Save XP, learned letters, settings |
| `google_fonts` | ^6.1.0 | Nunito + Fredoka One fonts |
| `provider` | ^6.1.1 | State management |
| `lottie` | ^3.0.0 | Animations |
| `audioplayers` | ^6.0.0 | Sound effects |

---

## 🎮 Screens & Features

### 🏠 Home Screen
- Mascot (floating unicorn animation)
- XP bar, Level badge, Streak, Stars, Rank
- 4 nav cards: Lessons, Game Zone, Progress (locked), Parents

### 📖 Lessons Screen
- Letter Sounds A–Z (with 🔊 speaker per row)
- Vowel Sounds
- Rhyming Words (with progress bar)
- Alphabet Order (locked / coming soon)

### 🔤 Letter Sounds A–Z
- Big letter + picture side by side (e.g., A 🍎)
- Large gold speaker button → TTS pronunciation
- Prev / Next navigation
- 26-letter grid with learned ⭐ tracking

### 🎮 Game Zone
- **Entertainment**: Sound Match (+15 XP), Memory Flip (+20 XP)
- **Academic**: Phonics Quiz (+25 XP), Word Builder (+30 XP)
- Alphabet Order (coming soon)

### 🔊 Sound Match
- Big picture shown (e.g., 🍎 Apple)
- Pick the starting letter from 4 choices
- Voice feedback on correct/wrong answers
- Confetti on correct answer

### 🃏 Memory Flip
- 12 cards: 6 letters + 6 matching pictures
- Flip to reveal, match letter ↔ picture
- Try-counter dots, match counter
- Win dialog with +20 XP

### ❓ Phonics Quiz
- Big picture clue (e.g., 🐶)
- 4 letter choices shown as picture+letter cards
- Voice hint button
- Progress bar across 5 questions
- Results screen

### 🔡 Word Builder
- 5 picture puzzles (CAT, DOG, SUN, APE, FIN)
- Fill in the missing letter(s)
- Shake animation on wrong answer
- Voice guide: "C... blank... T"

### 👨‍👩‍👧 Parent Panel
- Today's stats (Lessons, XP, Time)
- Toggles: Voice, Sound Effects, Game Access, Time Limit
- Weekly lessons bar chart
- Learned letters A–Z tracker

---

## 🎨 Design System

| Token | Value |
|---|---|
| Background | `#0F0A2E` (deep space) |
| Gold | `#FFD700` |
| Teal | `#00BFA5` |
| Pink | `#FF6B9D` |
| Purple | `#6A1B9A` |
| Font (headings) | Fredoka One |
| Font (body) | Nunito 700–900 |

---

## 🔧 Customization

### Add more letters/pictures
Edit `lib/data/letter_data.dart` → `allLetters` list

### Add more quiz questions
Edit `lib/data/letter_data.dart` → `quizQuestions` list

### Add more word puzzles
Edit `lib/screens/word_builder_screen.dart` → `_puzzles` list

### Change TTS speed/pitch
Edit `lib/providers/app_provider.dart` → `_initTts()`

---

## 📋 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Voice**: flutter_tts (Text-to-Speech)
- **Persistence**: shared_preferences
- **Fonts**: google_fonts (Nunito, Fredoka One)
- **Target**: Android (API 21+ / Android 5.0+)

---

## 👨‍🏫 For the Research / Capstone

This prototype aligns with:
- **ISO/IEC 25010** — Usability, Reliability, Efficiency
- **Agile Methodology** — Iterative development with 5 phases
- **Grade 1 Target Users** — Salapingao Elementary School
- **Research Design** — Descriptive-Developmental

---

*KidsPhonics — JITLEES Group | PSU Capstone 2025–2026*
