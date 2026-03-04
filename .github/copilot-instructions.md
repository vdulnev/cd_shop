# Copilot Coding Agent Onboarding Guide

This repository contains a multi-platform Flutter application for an e-commerce storefront ("CD Shop"). Use this guide to quickly understand the codebase and reliably build, run, and validate changes.

## Overview
- Purpose: Cross-platform shopping app with product listing, search, account auth, and detail pages.
- Project Type: Flutter app targeting Android, iOS, Web, macOS, Windows, Linux.
- Stack: Dart, Flutter; state via `flutter_riverpod`; routing via `auto_route`; DI via `get_it`; persistence via Firebase/Firestore; functional error handling with `dartz`.
- Architecture: Clean Architecture with feature-based organization.

## Build & Development Commands

```bash
# Bootstrap dependencies
flutter pub get

# Analyze code (required before PRs - expect zero issues)
flutter analyze

# Run tests
flutter test

# Run app on connected device/emulator
flutter run

# Build for web
flutter build web

# Clean and re-bootstrap
flutter clean && flutter pub get
```

## Commit Message Convention

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or updating tests
- `chore`: Changes to build process or auxiliary tools

### Scope (optional)
Use the feature or area affected: `auth`, `product`, `cart`, `order`, `address`, `core`, `router`, `test`, `ci`, `deps`

### Examples
```
feat(auth): add password reset functionality
fix(cart): correct total calculation with tax
test(product): add unit tests for product search
refactor(core): simplify error handling logic
chore(deps): update firebase_core to 4.4.0
```

## Git & Commit Rules

**No Automatic Commits**: Never commit changes without explicit user command. Always:
1. Show the changes to be committed
2. Wait for user confirmation with "commit" command
3. Then execute the commit

## Architecture Overview

CD Shop uses Clean Architecture with feature-based organization.

### Layer Structure (per feature)
```
lib/features/<feature>/
├── data/
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business objects
│   ├── repositories/    # Abstract repository contracts
│   └── usecases/        # Single-purpose business logic
└── presentation/
    ├── providers/       # Riverpod Notifiers & Providers
    ├── pages/           # Screen widgets
    └── widgets/         # Feature-specific widgets
```

### Key Architectural Rules

**Page-Notifier Isolation**: Each page uses ONLY its corresponding Notifier(s). Data needed from other features is passed via constructor parameters or typed route arguments.

**No Foreign State Access in Widgets**: Widgets must never access Notifiers/Providers from other features directly. Instead:
- Pages (top-level) call foreign usecases and inject callbacks to child widgets.
- Child widgets receive pure callbacks with no knowledge of other features' implementation.

**Reactive Repositories**: Repositories expose `Stream` via `BehaviorSubject` for real-time updates. Use cases wrap repository methods. Notifiers subscribe to streams and emit state changes.

### Reactive Repository Rules
- **Primary API is streams**: Prefer `Stream<List<T>>` (e.g., `watchProducts()`) for live data. Avoid wrapping streams in `Either`; propagate failures via the stream error channel.
- **Non-blocking initialization**: Trigger seeding in the repository constructor without awaiting in method calls. Do not call init per-method.
- **Domain-only emissions**: Streams should emit domain models; convert entities in the repository layer.
- **UI subscription**: Notifiers subscribe to streams and update state on data; handle errors via `onError` to surface user-friendly messages.

### Event & Analytics Emitters

- **App Event Emitters**: Any class implementing `EventEmitter` must be included in the `emitters` list inside `appEventProvider` so repository events are surfaced to the app event stream.
- **Analytics Emitters**: Any class implementing `AnalyticsEmitter` must be included in the `emitters` list inside `AnalyticsObserver` so analytics events are observed and logged.

**Dependency Injection**: All dependencies registered in `lib/injection_container.dart`. Features initialize in order: Auth → Product → Cart → Address → Order → Core BLoCs. Do not create intermediate providers that merely wrap `sl()` calls; inject usecases directly via `sl()` in notifier factories.

**Riverpod Providers**: Use the modern `Notifier`/`NotifierProvider` API (from `flutter_riverpod/flutter_riverpod.dart`). Do not use the legacy `StateNotifier`/`StateNotifierProvider` (from `flutter_riverpod/legacy.dart`). Do not use `riverpod_generator` or `riverpod_annotation`. Declare providers manually (e.g., `NotifierProvider<MyNotifier, MyState>(MyNotifier.new)`).

**No Null Assertion Operator**: Do not use the null assertion operator (`!`). Use safe access (`?.`) and explicit null checks instead.

### Core Components

- **Persistence**: Firebase/Firestore is the single source of truth.

- **Routing**: auto_route with `AutoTabsRouter` for tab navigation. Routes are defined in `lib/router/app_router.dart` and generated into `app_router.gr.dart`. All pages are annotated with `@RoutePage()`. Tab shell pages live in `lib/router/tab_pages.dart`.

- **App Events**: Repository events (success/error) flow through `StreamController.broadcast()` → `AppEventBloc` → `AppEventWidget` → snackbars via `lib/core/widgets/snackbar_helper.dart`.

- **Error Handling**: `dartz` `Either<Failure, T>` for repository returns. Failure types in `lib/core/error/failures.dart`.

### Features

| Feature | Notifiers | Purpose |
|---------|-----------|---------|
| auth | AccountNotifier, LoginNotifier, RegistrationNotifier | User authentication and session |
| product | ProductListNotifier, ProductSearchNotifier, ProductDetailNotifier | Product catalog |
| cart | CartNotifier | Shopping cart with real-time updates |
| address | AddressNotifier | User address management |
| order | CheckoutNotifier, OrderListNotifier | Checkout flow and order history |

## Testing Notes

- Initialize DI before pumping widgets: `await initDependencies()`
- Flush fake delays: `await tester.pump(const Duration(seconds: 1))`
- Provider tests use `flutter_test` with `mocktail` for mocking

## Known Issues & Workarounds
- Analyze non-zero:
  - Add missing packages (e.g., `flutter pub add stream_transform`).
- Widget tests failing (DI/timers):
  - Initialize DI with `await initDependencies()` before pumping `App`.
  - Flush fake delays with `await tester.pump(const Duration(seconds: 1))`.

## Project Layout
- Entry: `lib/main.dart` (init DI, run `App`).
- App shell: `lib/app.dart` sets `MaterialApp.router` with theming and routing.
- Routing: `lib/router/app_router.dart` uses `auto_route` with `AutoTabsRouter` for tabs.
- DI: `lib/injection_container.dart` registers feature providers/use cases/repos.
- Features: `lib/features/<feature>/{data,domain,presentation}/` with clean architecture layering.
- Core: `lib/core/error/failures.dart`, `lib/core/widgets/`, `lib/core/theme/`.
- Platforms: Standard Flutter folders for android, ios, macos, linux, windows, web.

## Repo Root Highlights
- `pubspec.yaml`, `pubspec.lock`: dependencies and constraints.
- `analysis_options.yaml`: lint rules.
- `CLAUDE.md`: detailed architecture and testing guidance.
- Source root: `lib/` with `core/`, `features/`, `router/`, `app.dart`, `main.dart`.
