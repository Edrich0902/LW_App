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

### 4. Theming & Branding
- **Strict Adherence:** Follow the guidelines in `THEME.md` for all UI changes.
- **Color Usage:** Always use `Theme.of(context)` or the `LightColors`/`DarkColors` constants.
- **Sleek & Modern:** Maintain the "Flat & Seamless" aesthetic (Elevation 0 for AppBars/Buttons).
- **Navigation:** Bottom navigation in Dark Mode uses Charcoal (`#1E1E1E`) to balance the Gold accents.

### 5. Behavioral Constraints
- **NO Unapproved Text Changes:** Do NOT update user-facing labels, menu titles, or messages without explicit confirmation.
- **Afrikaans UI:** Maintain all UI-facing content in **Afrikaans**.


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
7.  **SnackBars & Notifications:** NEVER use the base Flutter `SnackBar` or the `animated_snack_bar` package directly. Always use the `LwpSnackbar` wrapper for showing user feedback, success messages, or errors.
    -   Example: `LwpSnackbar.showSuccess(context, 'Boodskap');`
8.  **Language & Localization:** All UI-facing content (labels, messages, buttons) MUST be in **Afrikaans**. Code-level naming (variables, files, classes) remains in **English**.
9.  **Card UI Conventions:**
    -   Use a consistent border radius of `24.0` for all cards (defined in `AppTheme`).
    -   When listing details within a card (e.g., EFT details), use fixed-width labels (e.g., `130.0`) to ensure perfect vertical alignment across rows.
    -   Prevent text wrapping for short labels by using `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
    -   Use `Divider(height: 32)` to separate sections within a card.
10. **Calendar Integration:** When adding events/courses to the device calendar:
    -   Use the `add_2_calendar_new` package.
    -   Handle recurring events by mapping `EventType` to the `Frequency` enum.
    -   Parse time strings (e.g., `18:00:00+00`) by splitting at the timezone offset.
    -   Ensure `startDate` and `endDate` (for recurrence) are correctly handled as `DateTime` objects.

## Key Files

-   `pubspec.yaml`: Project dependencies and asset configuration.
-   `lib/main.dart`: Application entry point and MultiBlocProvider setup.
-   `lib/Utils/environment.dart`: Configuration for environment variables.
-   `analysis_options.yaml`: Linting and static analysis rules.
