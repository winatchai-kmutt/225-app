# a255_app

A Flutter application built with Clean Architecture principles and Neo-Brutalist design system.

## Project Structure

This project follows Flutter Clean Architecture with feature-based organization:

```
lib/
├── config/                          # Global Configuration
│   ├── app_config.dart              # Environment and feature flags
│   └── app_router.dart              # Centralized routing (GoRouter)
│
├── features/                        # Feature Modules
│   ├── common/                      # Shared Design System
│   │   ├── themes/                  # Theme tokens (colors, typography, shapes)
│   │   ├── widgets/                 # Reusable UI components (NeoContainer, CustomScaffold)
│   │   └── utils/                   # Utility functions
│   │
│   └── storage/                     # Centralized Data Layer
│       ├── domain/                  # Domain Layer (entities, repository interfaces)
│       │   ├── entities/            # Business entities
│       │   └── repos/               # Repository interfaces
│       └── data/                    # Data Layer (repository implementations)
│
├── main.dart                        # Application entry point
└── app.dart                         # Application bootstrap (DI + routing setup)
```

## Architecture Principles

- **Spec-Driven Development**: All features start with specifications in `/specs/`
- **Clean Architecture**: Strict layer separation (Presentation → Domain → Data)
- **Theme Compliance**: All UI uses theme tokens from `lib/features/common/themes/`
- **Centralized Routing**: `app_router.dart` owns all navigation paths
- **State Management**: BLoC/Cubit pattern with separate state files

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.0+

### Installation

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Tech Stack

- **Routing**: [go_router](https://pub.dev/packages/go_router) ^14.6.1
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) ^8.1.6
- **Value Equality**: [equatable](https://pub.dev/packages/equatable) ^2.0.7
- **Typography**: [google_fonts](https://pub.dev/packages/google_fonts) ^6.1.0

## Design System

This project uses a Neo-Brutalist design system with:
- Bold, thick borders (1.5px)
- Hard drop shadows (no blur)
- Vibrant accent colors
- Clean typography with Inter font family

See `/specs/003-foundation-setup/` for detailed design specifications.
