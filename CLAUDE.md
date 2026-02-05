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

**Use Cases as Interfaces**: All use cases must be defined as abstract interface classes.
- Create a concrete implementation class suffixed with `Impl` (e.g., `class GetUserImpl implements GetUser`).
- Annotate the implementation with `@LazySingleton(as: InterfaceName)` to register it against the interface.

**No Direct Repository Access in Notifiers**: Notifiers must never depend on repositories directly. All data access goes through use case classes (`domain/usecases/`).

**Reactive Repositories**: Repositories expose `Stream` via `BehaviorSubject` or `StreamController` for real-time updates. Use cases wrap repository methods. Notifiers subscribe to streams and emit state changes.

**Dependency Injection**: Dependencies are managed by `get_it` and `injectable`.
-   Annotate implementation classes with `@LazySingleton(as: Interface)`.
-   Run `flutter pub run build_runner build` to generate `lib/injection_container.config.dart`.
-   Do not manually register dependencies in `injection_container.dart` except for external modules in `lib/core/di/register_module.dart`.

**Riverpod Providers**: Use the modern `Notifier`/`NotifierProvider` API.
- Do not use `riverpod_generator` or `riverpod_annotation`.
- Declare providers manually (e.g., `NotifierProvider<MyNotifier, MyState>(MyNotifier.new)`).

**No Null Assertion Operator**: Do not use the null assertion operator (`!`). Use safe access (`?.`) and explicit null checks instead.

**App Event Emitters**: Any class implementing `EventEmitter` must be included in the `emitters` list inside `appEventProvider`.

**Analytics Emitters**: Any class implementing `AnalyticsEmitter` must be included in the `emitters` list inside `AnalyticsObserver`.

### Core Components

- **Persistence**: Firebase/Firestore is the single source of truth.

- **Routing**: GoRouter with `StatefulShellRoute.indexedStack` for tab navigation.

- **App Events**: Repository events flow through `StreamController.broadcast()` → `AppEventBloc` → `AppEventWidget` → snackbars.

- **Error Handling**: `dartz` `Either<Failure, T>` for repository returns.

### Features

| Feature | Notifiers | Purpose |
|---------|-----------|---------|
| auth | AccountNotifier, LoginNotifier, RegistrationNotifier | User authentication and session |
| product | ProductListNotifier, ProductSearchNotifier, ProductDetailNotifier | Product catalog |
| cart | CartNotifier | Shopping cart with real-time updates |
| address | AddressNotifier | User address management |
| order | CheckoutNotifier, OrderListNotifier | Checkout flow and order history |

## Testing Notes

- Initialize DI before pumping widgets: `await GetIt.instance.reset(); await initDependencies();` (or manually register mocks for unit tests).
- Flush fake delays: `await tester.pump(const Duration(seconds: 1))`
