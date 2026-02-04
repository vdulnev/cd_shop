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
    ├── providers/       # Riverpod Notifiers & Providers
    ├── pages/           # Screen widgets
    ├── routes/          # GoRouter route definitions
    └── widgets/         # Feature-specific widgets
```

### Riverpod File Structure

Each Notifier is potentially split into files (or kept together if small):
```
lib/features/<feature>/presentation/providers/
├── <name>_provider.dart    # Notifier class and Provider definition
└── <name>_state.dart       # Sealed state classes (optional separate file)
```

### Key Architectural Rules

**Page-Notifier Isolation**: Each page uses ONLY its corresponding Notifier(s). Data needed from other features is passed via constructor parameters or route `extra` data.

**No Foreign State Access in Widgets**: Widgets must never access Notifiers/Providers from other features directly. Instead:
- Pages (top-level) call foreign usecases and inject callbacks to child widgets.
- Child widgets receive pure callbacks with no knowledge of other features' implementation.

**No Direct Repository Access in Notifiers**: Notifiers must never depend on repositories directly. All data access goes through use case classes (`domain/usecases/`).

**Reactive Repositories**: Repositories expose `Stream` via `BehaviorSubject` or `StreamController` for real-time updates. Use cases wrap repository methods. Notifiers subscribe to streams and emit state changes.

**Dependency Injection**: All dependencies registered in `lib/injection_container.dart`. Features initialize in order: Auth → Product → Cart → Address → Order → Core BLoCs. Do not create intermediate providers that simply wrap `sl()` calls (e.g., `getProductsProvider`); inject usecases directly via `sl<UseCase>()` in notifier factories for simplicity.

**Riverpod Providers**: Use the modern `Notifier`/`NotifierProvider` API (from `flutter_riverpod/flutter_riverpod.dart`). Do not use the legacy `StateNotifier`/`StateNotifierProvider` (from `flutter_riverpod/legacy.dart`). Do not use `riverpod_generator` or `riverpod_annotation`. Declare providers manually (e.g., `NotifierProvider<MyNotifier, MyState>(MyNotifier.new)`).

**No Null Assertion Operator**: Do not use the null assertion operator (`!`). Use safe access (`?.`) and explicit null checks instead.

**App Event Emitters**: Any class implementing `EventEmitter` must be included in the `emitters` list inside `appEventProvider` so repository events are surfaced to the app event stream.

**Analytics Emitters**: Any class implementing `AnalyticsEmitter` must be included in the `emitters` list inside `AnalyticsObserver` so analytics events are observed and logged.

### Core Components

- **Persistence**: Firebase/Firestore is the single source of truth.

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
