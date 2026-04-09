# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

## Design

See [DESIGN.md](DESIGN.md) for UI/design guidelines (typography, color palette, component style, and general look & feel).

## Architecture

The app is currently a default Flutter starter. Architecture will evolve as features are added.

- **Entrypoint**: `lib/main.dart`
- **SDK**: Dart ^3.11.4, uses Material Design
- **Lint rules**: defined in `analysis_options.yaml` via `flutter_lints`
