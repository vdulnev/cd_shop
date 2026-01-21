# Copilot Coding Agent Onboarding Guide

This repository contains a multi-platform Flutter application for an e-commerce storefront ("CD Shop"). Use this guide to quickly understand the codebase and reliably build, run, and validate changes without trial-and-error.

## Overview
- Purpose: Cross-platform shopping app with product listing, search, account auth, and detail pages.
- Project Type: Flutter app targeting Android, iOS, Web, macOS, Windows, Linux.
- Languages/Frameworks: Dart, Flutter; State management via `flutter_bloc`; routing via `go_router`; DI via `get_it`/`injectable`; functional error handling with `dartz`.
- Repo Size: Typical Flutter app (platform folders + generated build outputs).

## Runtimes & Tooling
- Flutter: Verified with Flutter 3.38.0 (stable) on macOS.
- Dart: Matches pubspec constraint `3.10.0-290.4.beta` (Dart 3.10 beta).
- iOS/macOS builds require Xcode and CocoaPods; Android builds require Android SDK/Gradle; Web builds use Flutter’s web toolchain.

## Build & Validation
Follow this exact sequence. If a step fails, consult Known Issues & Workarounds.

### Bootstrap (always do first)
```bash
flutter --version
dart --version
flutter pub get
```
Preconditions: Flutter SDK installed and on PATH; internet access.
Postconditions: Dependencies resolved; tool versions captured for logs.

### Lint & Analyze (required pre-PR)
```bash
flutter analyze
```
Notes: Analysis may exit non-zero for info-level lints. See Known Issues.

### Test (if tests exist)
```bash
flutter test
```
Current state: No `test/` directory, so this command fails. Prefer to add tests or skip this step until tests are present.

### Run (local dev)
```bash
# Pick a target device/platform you have configured
flutter run
```
Postconditions: App launches on the selected device/emulator/simulator.

### Build (non-interactive validation)
```bash
# Web (fastest, validated)
flutter build web

# macOS (requires Xcode toolchain)
# flutter build macos

# iOS (use no-codesign for local validation)
# flutter build ios --no-codesign

# Android APK
# flutter build apk
```
Validated: `flutter build web` succeeds, with a font warning (see Known Issues).

### Clean & Re-bootstrap (when build output causes issues)
```bash
flutter clean
flutter pub get
```
Use when switching targets or after toolchain upgrades.


## Project Layout & Architecture
- Entry points & app setup:
  - `lib/main.dart`: Initializes Flutter and calls `initDependencies()`, then `runApp(App())`.
  - `lib/app.dart`: Configures `MaterialApp.router` with themes and router.
  - `lib/injection_container.dart`: Registers DI with `get_it` for features (auth, product) including BLoCs, use cases, repositories.
- Routing:
  - `lib/router/app_router.dart`: `go_router` config with `StatefulShellRoute.indexedStack` for tabs (`/`, `/search`, `/account`), nested product detail (`/products/:id`), account flows (`/account/login`, `/account/register`). Future: `/cart`, `/checkout`.
- Architecture (Clean Architecture):
  - `lib/features/<feature>/{data,domain,presentation}/`
    - Domain: entities, repositories, use cases.
    - Data: repository implementations.
    - Presentation: pages, widgets, BLoCs.
- Core modules:
  - `lib/core/error/failures.dart`: `Failure` hierarchy (server, network, auth, cache, etc.).
  - `lib/core/usecases/usecase.dart`: `UseCase<T, Params>` with `Either<Failure, T>`.
  - `lib/core/theme/`, `lib/core/constants/`: theming and constants.
- Configuration:
  - Lints: `analysis_options.yaml` (includes `flutter_lints` and additional rules).
  - Dependencies: `pubspec.yaml`.
- Platforms:
  - Android/iOS/macos/linux/windows/web directories are standard Flutter scaffolding.

## Local Checks Before PR
Run these in order and fix failures/warnings before submitting:
```bash
flutter pub get
flutter analyze
flutter build web
# Optionally: flutter build ios --no-codesign (macOS), flutter build apk (Android)
```
If `flutter analyze` returns non-zero, resolve dependency and style issues noted above.

## Dependencies to Watch
- Add missing imports as dependencies in `pubspec.yaml` (e.g., `stream_transform`).
- DI expects all repositories and use cases to be registered in `lib/injection_container.dart`.

## Repo Root Highlights
- `pubspec.yaml` / `pubspec.lock`: Dependencies and constraints.
- `analysis_options.yaml`: Lint rules.
- `README.md`: Minimal placeholder.
- Platform folders: `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`.
- App source: `lib/` with `core/`, `features/`, `router/`, `app.dart`, `main.dart`.

## Trust These Instructions
Follow this guide first. Only search the codebase if instructions are incomplete or appear incorrect for your task or environment.