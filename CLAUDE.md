# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

CD Shop is a Flutter e-commerce app using Clean Architecture with feature-based organization.

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

### BLoC File Structure

Each BLoC is split into three files:
```
lib/features/<feature>/presentation/bloc/
├── <name>_bloc.dart    # BLoC class (imports + re-exports event/state)
├── <name>_event.dart   # Sealed event classes
└── <name>_state.dart   # Sealed state classes
```
The `_bloc.dart` file imports and re-exports the event/state files, so consumers only need to import `_bloc.dart`.

### Key Architectural Rules

**Page-Bloc Isolation**: Each page uses ONLY its corresponding BLoC. Data needed from other features is passed via constructor parameters or route `extra` data, never by reading other BLoCs directly.

**No Foreign Bloc/State Access in Widgets**: Widgets must never access BLoCs or state managers from other features directly. Instead:
- Pages (top-level) call foreign usecases and inject callbacks to child widgets.
- Child widgets receive pure callbacks with no knowledge of other features' implementation.
- Example: ProductDetailPage calls `AddToCart` usecase, passes result callback to _AddToCartBar.

**No Direct Repository Access in BLoCs**: BLoCs must never depend on repositories directly. All data access goes through use case classes (`domain/usecases/`).

**Reactive Repositories**: Repositories expose `Stream` via `BehaviorSubject` for real-time updates. Use cases wrap repository methods. BLoCs subscribe to streams and emit state changes.

**Dependency Injection**: All dependencies registered in `lib/injection_container.dart`. Features initialize in order: Database → Auth → Product → Cart → Address → Order → Core BLoCs. Do not create intermediate providers that simply wrap `sl()` calls (e.g., `getProductsProvider`); inject usecases directly via `sl<UseCase>()` in notifier factories for simplicity.

**Riverpod Providers**: Use the modern `Notifier`/`NotifierProvider` API (from `flutter_riverpod/flutter_riverpod.dart`). Do not use the legacy `StateNotifier`/`StateNotifierProvider` (from `flutter_riverpod/legacy.dart`). Do not use `riverpod_generator` or `riverpod_annotation` — they are incompatible with `floor_generator` due to a `source_gen` version conflict. Declare providers manually (e.g., `NotifierProvider<MyNotifier, MyState>(MyNotifier.new)`).

**App Event Emitters**: Any class implementing `EventEmitter` must be included in the `emitters` list inside `appEventProvider` so repository events are surfaced to the app event stream.

**Analytics Emitters**: Any class implementing `AnalyticsEmitter` must be included in the `emitters` list inside `AnalyticsObserver` so analytics events are observed and logged.

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
