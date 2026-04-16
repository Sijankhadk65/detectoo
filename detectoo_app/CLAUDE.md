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
│   │   ├── models/                    # built_value classes (immutable, JSON-serializable)
│   │   │   ├── plant.dart         # Plant + PlantHealthStatus (EnumClass)
│   │   │   ├── recovery.dart      # Plant recovery status
│   │   │   ├── recovery_plan.dart # Recovery plan with steps, do/don't lists
│   │   │   ├── reminder.dart      # Plant care reminder
│   │   │   ├── scan_result.dart   # Scan result + DetectedIssue
│   │   │   ├── serializers.dart   # Central serializer registry (StandardJsonPlugin)
│   │   │   ├── task.dart          # Task/todo item with due date
│   │   │   └── user.dart          # User profile model
│   │   ├── providers/             # Riverpod providers for state management
│   │   ├── widgets/
│   │   │   ├── bottom_nav_bar.dart  # Bottom navigation shell (Home, Plants, Scan, Profile tabs)
│   │   │   ├── detectoo_button.dart # Reusable full-width elevated/outlined button
│   │   │   ├── detectoo_card.dart   # Reusable bordered card container
│   │   │   ├── gradient_banner.dart # Reusable gradient header banner with decorative elements
│   │   │   ├── icon_badge.dart      # Reusable icon in a rounded colored container
│   │   │   ├── section_title.dart   # Reusable section heading with icon
│   │   │   └── status_chip.dart     # Reusable pill-shaped colored status badge
│   │   └── screens/
│   │       ├── splash_screen.dart       # Animated splash screen with staggered animations
│   │       ├── login_screen.dart        # App login screen
│   │       ├── home_screen.dart         # Dashboard of the application
│   │       ├── profile_screen.dart      # User profile screen
│   │       ├── plants_screen.dart       # Display a list of the plants owned by the user
│   │       ├── plant_detail_screen.dart # Detailed view of a single plant
│   │       ├── scan_screen.dart         # Scan photos of plants for any anomalies
│   │       └── recovery_screen.dart     # View the recovery plan for an affected plant
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

# Run build_runner (code generation for built_value)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for build_runner (auto-regenerate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

## Code Formatting

- **Formatter**: `dart format .` (default Dart formatter, line length 80)
- **Linter & type checking**: `flutter analyze` — handles both static analysis and type checking. Rules defined in `analysis_options.yaml` via `flutter_lints` package

## Key Conventions

- Always add documentation comments (`///`) to new functions and classes
- Navigation between screens must be done using named routes
- All route names are defined centrally in `lib/src/routes.dart`. When adding a new screen, add its route to `Routes` and register it in `app.dart`
- All data classes must be placed in `lib/src/models/` and use `built_value` + `built_collection` for immutability and JSON serialization. Each model file must have a corresponding `.g.dart` generated part file. After modifying models, run `dart run build_runner build --delete-conflicting-outputs`. New serializable types must be registered in `serializers.dart`
- Model files that import both `built_value` and `package:flutter/material.dart` must use `hide Builder` on the material import to avoid name conflicts (e.g. `import 'package:flutter/material.dart' hide Builder;`)
- `IconData` fields are not serializable — store as `int iconCodePoint` and provide a `@BuiltValueField(serialize: false)` getter that returns `IconData(iconCodePoint, fontFamily: 'MaterialIcons')`
- Enums that need serialization should use `EnumClass` from `built_value`. UI-specific properties (labels, colors) should be added via extensions rather than stored in the enum itself
- All Riverpod providers must be placed in `lib/src/providers/`
- Reusable UI components must be placed in `lib/src/widgets/`. Before creating inline widget builders in screens, check if an existing reusable widget can be used (e.g., `SectionTitle`, `DetectooCard`, `IconBadge`, `StatusChip`, `DetectooButton`)

## Design

See [DESIGN.md](DESIGN.md) for UI/design guidelines (typography, color palette, component style, and general look & feel).

## Architecture

- **Entrypoint**: `lib/main.dart` — wraps `DetectooApp` in a Riverpod `ProviderScope`
- **App shell**: `lib/src/app.dart` — `MaterialApp` with Material 3, green theme, named routes
- **Routing**: `lib/src/routes.dart` — `Routes` class with all route name constants
- **Navigation**: Splash → Login → `BottomNavBar` (wraps Home, Plants, Scan, Profile tabs via `IndexedStack`). Plant Detail and Recovery are standalone routes navigated to from within other screens
- **State management**: Riverpod (`flutter_riverpod`). Providers live in `lib/src/providers/`. Screens use `ConsumerWidget` / `ConsumerStatefulWidget` to read providers
- **Data models**: `built_value` + `built_collection` for immutable, JSON-serializable classes with code generation via `build_runner`
- **SDK**: Dart ^3.11.4, uses Material Design 3
- **Lint rules**: defined in `analysis_options.yaml` via `flutter_lints`
