Project: BallPark - Mental Math Trainer
1. Vision & Goal
BallPark is a beautiful, polished, and offline-first Flutter application for mobile (iOS/Android) and web. It helps users train consulting-style mental math by providing timed, genre-specific problem sets with a focus on approximation and speed.

2. Core Technologies
Framework: Flutter

State Management: Provider (or Riverpod, for its simplicity and power)

Local Storage: shared_preferences for storing user statistics.

Charts: fl_chart for visualizing performance data.

Dependencies:

provider or flutter_riverpod

shared_preferences

fl_chart

google_fonts (for polished typography, e.g., 'Poppins' or 'Inter')

3. Application Architecture
The app will follow a standard feature-first folder structure.

lib/
├── main.dart
├── app/
│   ├── theme/          # App theme, colors, text styles
│   └── router/         # Navigation logic
├── features/
│   ├── home/
│   │   ├── screens/
│   │   └── widgets/
│   ├── problem/
│   │   ├── screens/
│   │   ├── widgets/    # custom_keypad.dart
│   │   └── view_models/
│   ├── results/
│   │   ├── screens/
│   │   └── widgets/
│   ├── stats/
│   │   ├── screens/
│   │   └── widgets/
├── models/             # Data models (Problem, SessionResult, etc.)
│   └── genre.dart
├── services/
│   ├── problem_generator_service.dart
│   ├── local_storage_service.dart
└── utils/              # Helper functions (e.g., number formatting)

4. Key Features & Logic
Home Screen: Configure session (Genre, Precision, Time).

Problem Screen: Core training loop with a custom keypad.

Results Screen: Post-session summary and detailed breakdown.

Stats Screen: Lifetime performance dashboard with charts.

Problem Generation: A ProblemGeneratorService will contain the specific rules for all 12 genres.

Input Handling: The custom keypad is the primary input. On the web, keyboard input will be listened for, but only keys corresponding to the keypad (0-9, ., Enter, Backspace, k, m, b) will be processed.

Offline First: All data is stored locally using shared_preferences. No server or login is required.