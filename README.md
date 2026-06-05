# Flutter Fintech

A premium, responsive Flutter crypto/investing app prototype with a highly polished custom UI and backend-ready local architecture.

The app focuses on design quality, motion, reusable structure, and functional local flows. Real exchange, custody, KYC, banking, and payment integrations are intentionally mocked behind repository interfaces so they can be replaced later.

## Highlights

- Premium aurora/glassmorphism design system
- Animated dashboard with portfolio value, allocation, watchlist, insights, and activity
- Backend-ready crypto domain models and repositories
- Mock backend with simulated latency, market ticks, orders, transfers, and persistence
- Functional buy/sell, transfer/deposit/withdraw, card controls, watchlist, reports, and settings
- Responsive mobile-first layout with wider screen support
- Widget and controller tests

## Project Structure

```text
lib/
  main.dart
  src/
    app.dart
    data/          Repository interfaces and mock backend services
    domain/        Pure crypto models and serialized app snapshot
    models/        UI display models used by premium components
    screens/       Dashboard, analytics, wallet, payments, profile, shell
    state/         App controller and inherited app scope
    theme/         Colors, gradients, typography, theme overrides
    utils/         Formatting and UI helper functions
    widgets/       Reusable premium components and action sheets
test/
  app_controller_test.dart
  widget_test.dart
```

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run checks:

```bash
dart format .
flutter analyze
flutter test
```

Build Android debug APK:

```bash
flutter build apk --debug
```

## Android Build Note

On Windows, Flutter may ask for Developer Mode when plugins require symlink support. If Kotlin daemon incremental cache errors occur, this project already includes the safer Gradle settings:

```properties
kotlin.compiler.execution.strategy=in-process
kotlin.incremental=false
```

## Mocked Backend Surfaces

The app currently uses local mock implementations for:

- Market prices and market ticks
- Portfolio persistence
- Buy/sell order execution
- Transfers, deposits, and withdrawals
- Card controls
- Profile/settings persistence

These are intentionally placed behind repository interfaces in `lib/src/data/` so real APIs can be integrated later without rewriting the screens.