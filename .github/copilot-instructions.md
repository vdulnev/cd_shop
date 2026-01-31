# Copilot Coding Agent Onboarding Guide

This repository contains a multi-platform Flutter application for an e-commerce storefront ("CD Shop"). Use this guide to quickly understand the codebase and reliably build, run, and validate changes.

## Overview
- Purpose: Cross-platform shopping app with product listing, search, account auth, and detail pages.
- Project Type: Flutter app targeting Android, iOS, Web, macOS, Windows, Linux.
- Stack: Dart, Flutter; state via `flutter_riverpod`; routing via `go_router`; DI via `get_it`; database via Floor (SQLite); functional error handling with `dartz`.
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

# Regenerate Floor database code after entity/DAO changes
dart run build_runner build --delete-conflicting-outputs

# Clean and re-bootstrap
flutter clean && flutter pub get
```

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
    ├── bloc/            # BLoC state management
    ├── pages/           # Screen widgets
    ├── routes/          # GoRouter route definitions
    └── widgets/         # Feature-specific widgets
```

### Key Architectural Rules

**Page-Bloc Isolation**: Each page uses ONLY its corresponding BLoC. Data needed from other features is passed via constructor parameters or route `extra` data, never by reading other BLoCs directly.

**No Foreign Bloc Access in Widgets**: Widgets must never access BLoCs from other features (e.g., CartBloc in product widgets). Instead, use usecases or inject callbacks from parent pages. Example: ProductDetailPage injects an `AddToCart` usecase callback to _AddToCartBar, keeping cart logic isolated.

**Reactive Repositories**: Repositories expose `Stream` via `BehaviorSubject` for real-time updates. Use cases wrap repository methods. BLoCs subscribe to streams and emit state changes.

### Reactive Repository Rules
- **Primary API is streams**: Prefer `Stream<List<T>>` (e.g., `watchProducts()`) for live data. Avoid wrapping streams in `Either`; propagate failures via the stream error channel.
- **Floor streaming queries**: Implement DAO methods using Floor `@Query` returning `Stream<List<Entity>>` (e.g., `ProductDao.watchAllProducts()`). Map entities to domain in the repository.
- **Non-blocking initialization**: Trigger seeding in the repository constructor without awaiting in method calls. Do not call init per-method.
- **Persist initialization state**: Track one-time seeds using a dedicated settings table (e.g., `app_settings` with key `products_seeded`) rather than checking table emptiness.
- **Domain-only emissions**: Streams should emit domain models; convert entities in the repository layer.
- **UI subscription**: Notifiers/BLoCs subscribe to streams and update state on data; handle errors via `onError` to surface user-friendly messages.

### Event & Analytics Emitters

- **App Event Emitters**: Any class implementing `EventEmitter` must be included in the `emitters` list inside `appEventProvider` so repository events are surfaced to the app event stream.
- **Analytics Emitters**: Any class implementing `AnalyticsEmitter` must be included in the `emitters` list inside `AnalyticsObserver` so analytics events are observed and logged.

**Dependency Injection**: All dependencies registered in `lib/injection_container.dart`. Features initialize in order: Database → Auth → Product → Cart → Address → Order → Core BLoCs. Do not create intermediate providers that merely wrap `sl()` calls; inject usecases directly via `sl()` in notifier factories.

**Riverpod Providers**: Use the modern `Notifier`/`NotifierProvider` API (from `flutter_riverpod/flutter_riverpod.dart`). Do not use the legacy `StateNotifier`/`StateNotifierProvider` (from `flutter_riverpod/legacy.dart`). Do not use `riverpod_generator` or `riverpod_annotation` — they are incompatible with `floor_generator` due to a `source_gen` version conflict. Declare providers manually (e.g., `NotifierProvider<MyNotifier, MyState>(MyNotifier.new)`).

### Core Components

- **Database**: Floor (SQLite) with DAOs in `lib/core/database/daos/` and entities in `lib/core/database/entities/`. Migrations defined in `app_database.dart`.

- **Routing**: GoRouter with `StatefulShellRoute.indexedStack` for tab navigation. Each feature defines routes in `presentation/routes/`. Routes aggregate in `lib/router/app_router.dart`.

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
- BLoC tests use `bloc_test` package with `mocktail` for mocking

## Known Issues & Workarounds
- Analyze non-zero:
  - Add missing packages (e.g., `flutter pub add stream_transform`).
- Widget tests failing (DI/timers):
  - Initialize DI with `await initDependencies()` before pumping `App`.
  - Flush fake delays with `await tester.pump(const Duration(seconds: 1))`.

## Project Layout
- Entry: `lib/main.dart` (init DI, run `App`).
- App shell: `lib/app.dart` sets `MaterialApp.router` with theming and routing.
- Routing: `lib/router/app_router.dart` uses `go_router` with `StatefulShellRoute.indexedStack` for tabs.
- DI: `lib/injection_container.dart` registers feature blocs/use cases/repos.
- Features: `lib/features/<feature>/{data,domain,presentation}/` with clean architecture layering.
- Core: `lib/core/error/failures.dart`, `lib/core/database/`, `lib/core/widgets/`, `lib/core/theme/`.
- Platforms: Standard Flutter folders for android, ios, macos, linux, windows, web.

## Repo Root Highlights
- `pubspec.yaml`, `pubspec.lock`: dependencies and constraints.
- `analysis_options.yaml`: lint rules.
- `CLAUDE.md`: detailed architecture and testing guidance.
- Source root: `lib/` with `core/`, `features/`, `router/`, `app.dart`, `main.dart`.
