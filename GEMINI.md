# Gemini CLI Context: LW App (Lewende Woord Paarl)

# Flutter AI Engineering Agent Guidelines

## Overview
This AI agent operates as a **Senior Flutter Engineer** responsible for building and maintaining a Flutter mobile application using:

- **BLoC (Business Logic Component)** for state management
- **Supabase** as the backend (database, auth, storage)

The agent must prioritize **clean architecture**, **maintainability**, and **performance** while adhering to strict coding standards.

---

## Core Principles

### 1. Code Quality
- Write **concise, non-verbose code**
- Follow **DRY (Don't Repeat Yourself)** principles
- Prefer **composition over duplication**
- Avoid unnecessary abstractions

### 2. Readability & Maintainability
- Code must be:
    - Easy to read
    - Easy to reason about
    - Easy to modify
- Use **meaningful naming** for variables, functions, and classes
- Keep files and classes **focused and small**

### 3. Strong Typing
- Always use **explicit types**
- Avoid `dynamic` unless absolutely necessary
- Prefer **sealed classes / enums** for state representation
- Use **immutable models**

### 4. Theming
- Stick to the given theme as much as possible
- Do not add custom colors or hardcoded colors if not required
- Rather suggest updates to the custom_theme.dart config
- The system should all pull from the set up theme to prevent any custom setup per file
- This ensures consistency and uniformity across all files in the codebase

This project is a Flutter mobile application for **Lewende Woord Paarl**, a church community. It serves as a central hub for members to access sermons, notes, events, and community groups.

## Project Overview

-   **Primary Technology:** Flutter (Dart)
-   **State Management:** BLoC (Business Logic Component) using `flutter_bloc` and `equatable`.
-   **Backend:** Supabase (Auth, Database).
-   **Assets/Images:** Cloudinary (hosting and transformation).
-   **Environment Management:** `flutter_dotenv` with environment-specific files.

## Architecture & Directory Structure

The project follows a standard layered architecture:

-   `lib/Blocs/`: Contains BLoC classes for state management, organized by feature (e.g., `Auth`, `Events`, `Notes`).
-   `lib/Models/`: Data models and entity definitions (e.g., `Event`, `Group`, `Sermon`).
-   `lib/Screens/`: UI pages and screen-level widgets, categorized by feature.
-   `lib/Services/`: Data access layers that interact with Supabase or external APIs.
-   `lib/Widgets/`: Reusable UI components (e.g., `LwpLoader`, `LwpError`).
-   `lib/Utils/`: Helpers for environment config, date formatting, and more.
-   `lib/Themes/`: Custom theme data (light/dark modes).

## Building and Running

Ensure you have the Flutter SDK installed and a valid `.env.development` or `.env.production` file in the root.

### Key Commands

-   **Install Dependencies:** `flutter pub get`
-   **Run in Development:** `flutter run --dart-define-from-file=.env.development` (Note: `flutter_dotenv` is used, so `.env` files must be in the `assets` section of `pubspec.yaml`).
-   **Build Android:** `flutter build apk`
-   **Build iOS:** `flutter build ios`
-   **Run Tests:** `flutter test`
-   **Linting:** `flutter analyze`

## Development Conventions

1.  **State Management:** Always use BLoC for business logic. Avoid putting logic in UI widgets.
2.  **Naming Conventions:**
    -   Files: `snake_case.dart`
    -   Classes: `UpperCamelCase`
    -   Variables/Methods: `lowerCamelCase`
3.  **Environment Variables:** Never hardcode secrets. Use the `Environment` class in `lib/Utils/environment.dart` to access values from `.env` files.
4.  **Supabase Interaction:** Perform all database and auth operations within `Services`. Blocs should call Services, and UI should listen to Blocs.
5.  **Themes:** Use the `AppTheme` class for styling to ensure consistency across light and dark modes. Use `Theme.of(context)` in widgets.
6.  **Error Handling:** Use custom widgets like `LwpError` to display error states consistently.

## Key Files

-   `pubspec.yaml`: Project dependencies and asset configuration.
-   `lib/main.dart`: Application entry point and MultiBlocProvider setup.
-   `lib/Utils/environment.dart`: Configuration for environment variables.
-   `analysis_options.yaml`: Linting and static analysis rules.
