# Copilot Coding Agent Onboarding Guide

This repository contains a multi-platform Flutter application for an e-commerce storefront ("CD Shop"). Use this guide to quickly understand the codebase and reliably build, run, and validate changes.

## Overview
- Purpose: Cross-platform shopping app with product listing, search, account auth, and detail pages.
- Project Type: Flutter app targeting Android, iOS, Web, macOS, Windows, Linux.
- Stack: Dart, Flutter; state via `flutter_bloc`; routing via `go_router`; DI via `get_it`/`injectable`; functional error handling with `dartz`.
- Repo Size: Typical Flutter app (platform folders + generated build outputs).

## Runtimes & Tooling
- Flutter: 3.38.0 (stable) on macOS.
- Dart: 3.10.0-290.4.beta (per pubspec constraint).
- Tooling: Xcode/CocoaPods for iOS/macOS; Android SDK/Gradle for Android; Flutter web toolchain for web.

## Build & Validation
Follow this sequence. If a step fails, see Known Issues & Workarounds.

### Bootstrap (always first)
```bash
flutter --version
dart --version
flutter pub get
```
- Preconditions: Flutter SDK on PATH; internet access.
- Postconditions: Dependencies resolved; tool versions captured.

### Lint & Analyze (required pre-PR)
```bash
flutter analyze
```
- Expect zero exit. Fix lints (e.g., prefer const, use_colored_box).

### Test
```bash
flutter test
```
- If widget tests pump `App`, initialize DI (`await initDependencies()`), and flush simulated delays if repositories use timers (`await tester.pump(const Duration(seconds: 1))`).

### Run (local dev)
```bash
flutter run
```
- Preconditions: Target device/emulator available.

### Build (non-interactive validation)
```bash
flutter build web
# Optional: flutter build ios --no-codesign
# Optional: flutter build apk
# Optional: flutter build macos
```
- Web build validated. If CupertinoIcons font warnings appear, add `cupertino_icons` to pubspec.

### Clean & Re-bootstrap
```bash
flutter clean
flutter pub get
```
- Use when switching targets or after toolchain upgrades.

## Local Checks Before PR
```bash
flutter pub get
flutter analyze
flutter test
flutter build web
# Optionally: flutter build ios --no-codesign (macOS), flutter build apk (Android)
```

## Dependencies to Watch
- repositories are reactive, use `BehaviorSubject` to implement streams.
- events for snackbars are produced in repositories via `StreamController.broadcast()`.
- `AppEventWidget` is used to subscribe to app-wide events (e.g., show snackbar).
- snackbars are shown via methods in `lib/core/widgets/snackbar_helper.dart`.
- `cupertino_icons`: required if using `CupertinoIcons`; resolves web font warnings.
- DI registrations live in `lib/injection_container.dart` — keep BLoCs/use cases/repos in sync.
- Product genres use the `ProductGenre` enum (non-null) in `lib/features/product/domain/entities/product.dart`; use `genreLabel` for display.

## Known Issues & Workarounds
- Analyze non-zero:
  - Add missing packages (e.g., `flutter pub add stream_transform`).
- Web build font warnings:
  - Add `cupertino_icons` when using `CupertinoIcons`.
- Widget tests failing (DI/timers):
  - Initialize DI with `await initDependencies()` before pumping `App`.
  - Flush fake delays with `await tester.pump(const Duration(seconds: 1))`.

## Project Layout & Architecture
- Entry: `lib/main.dart` (init DI, run `App`).
- App shell: `lib/app.dart` sets `MaterialApp.router` with theming and routing.
- Routing: `lib/router/app_router.dart` uses `go_router` with `StatefulShellRoute.indexedStack` for tabs (`/`, `/search`, `/account`), product detail `/products/:id`, account auth routes; future `/cart`, `/checkout` placeholders.
- DI: `lib/injection_container.dart` registers feature blocs/use cases/repos.
- Features: `lib/features/<feature>/{data,domain,presentation}/` with clean architecture layering.
- Core: `lib/core/error/failures.dart`, `lib/core/usecases/usecase.dart`, `lib/core/theme/`, `lib/core/constants/`.
- Platforms: Standard Flutter folders for android, ios, macos, linux, windows, web.

## Repo Root Highlights
- `pubspec.yaml`, `pubspec.lock`: dependencies and constraints.
- `analysis_options.yaml`: lint rules.
- `README.md`: brief description.
- Source root: `lib/` with `core/`, `features/`, `router/`, `app.dart`, `main.dart`.

## Trust These Instructions
Follow this guide first. Only search the codebase if instructions are incomplete or incorrect for your task or environment.
