# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
This is an application that will help users detect diseases in their plants, come up with a recovery plan. The application is built using flutter.

## Project Structure

```
detectoo_app
├── android/    
├── ios/
├── linux/
├── macos/
├── windows/
├── web/
├── lib/
│   ├── main.dart     # Entry point
│   ├── src/
│   │   ├── app.dart    # MaterialApp with theme, named routes, and initial route
│   │   ├── routes.dart # Centralized route name constants (Routes class)
│   │   ├── models/
│   │   │   ├── reminder.dart  # Plant care reminder data class
│   │   │   ├── task.dart      # Task/todo item data class
│   │   │   └── recovery.dart  # Plant recovery status data class
│   │   ├── widgets/
│   │   │   └── bottom_nav_bar.dart  # Bottom navigation shell (Home, Plants, Scan, Profile tabs)
│   │   └── screens/
│   │       ├── login_screen.dart     # App login screen
│   │       ├── home_screen.dart      # Dashboard of the application
│   │       ├── profile_screen.dart   # User profile screen
│   │       ├── plants_screen.dart    # Display a list of the plants owned by the user
│   │       ├── scan_screen.dart      # Scan photos of plants for any anomalies
│   │       └── recovery_screen.dart  # View the recovery plan for an affected plant
├── test/
|   └── widget_test.dart
├── CLAUDE.md
├── DESIGN.md
├── pubspec.yaml
└── README.md

```

## Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze
```

## Code Formatting

- **Formatter**: `dart format .` (default Dart formatter, line length 80)
- **Linter & type checking**: `flutter analyze` — handles both static analysis and type checking. Rules defined in `analysis_options.yaml` via `flutter_lints` package

## Key Conventions

- Always add documentation comments (`///`) to new functions and classes
- Navigation between screens must be done using named routes
- All route names are defined centrally in `lib/src/routes.dart`. When adding a new screen, add its route to `Routes` and register it in `app.dart`
- All data classes must be placed in `lib/src/models/`

## Design

See [DESIGN.md](DESIGN.md) for UI/design guidelines (typography, color palette, component style, and general look & feel).

## Architecture

- **Entrypoint**: `lib/main.dart` — runs `DetectooApp`
- **App shell**: `lib/src/app.dart` — `MaterialApp` with Material 3, green theme, named routes
- **Routing**: `lib/src/routes.dart` — `Routes` class with all route name constants
- **Navigation**: Login → `BottomNavBar` (wraps Home, Plants, Scan, Profile tabs via `IndexedStack`). Recovery is a standalone route navigated to from within other screens
- **SDK**: Dart ^3.11.4, uses Material Design 3
- **Lint rules**: defined in `analysis_options.yaml` via `flutter_lints`
