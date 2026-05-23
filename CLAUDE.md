# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter mobile app for **Lewende Woord Paarl** — a church community hub for sermons, notes, events, Bible reading, and community groups. All UI-facing text is in **Afrikaans**; code identifiers stay in English.

## Commands

```bash
flutter pub get                                              # install dependencies
flutter run --dart-define-from-file=.env.development        # run with dev config
flutter analyze                                             # lint and type-check
dart format .                                               # format Dart code
flutter test                                                # run tests
flutter test test/path/to/file_test.dart                    # run single test
flutter build apk                                           # Android build
flutter build ios                                           # iOS build (macOS + Xcode required)
```

After every code change run `flutter analyze` to verify structural and type integrity.

## Architecture

Strict layered architecture — each layer has one responsibility:

- **`lib/Screens/`** — route-level UI, organised by feature. Dispatches BLoC events and renders states only; no business logic.
- **`lib/Blocs/`** — feature BLoCs (`*_bloc.dart`, `*_event.dart`, `*_state.dart`). Calls Services; never touches Supabase or APIs directly.
- **`lib/Services/`** — all Supabase, REST API, and external integration calls live here.
- **`lib/Models/`** — typed, immutable data models and enums.
- **`lib/Widgets/`** — reusable UI components (prefixed `Lwp*` for project-level abstractions).
- **`lib/Utils/`** — `Environment`, `CloudinaryHelper`, date formatters, and map helpers.
- **`lib/Themes/`** — `AppTheme` (light/dark), `LightColors`, `DarkColors`.

`lib/main.dart` bootstraps Supabase, Cloudinary, and `dotenv`, then mounts all BLoCs via `MultiBlocProvider` before the app starts.

Navigation uses a bottom tab bar (`google_nav_bar`) in `lib/Screens/Container/container.dart` with five tabs: Tuis (Dashboard), Kalender, Bybel, Meer Oor Ons, Skakel In. Screens inside tabs push routes on top.

## Key Conventions

**State management:** BLoC only. UI → dispatches event → BLoC → calls Service → emits state → UI rebuilds. Never put Supabase calls in widgets.

**Environment config:** Use `lib/Utils/environment.dart` to read `.env.development` / `.env.production`. Never hardcode secrets or URLs. Both `.env.*` files are bundled as assets (see `pubspec.yaml`) and selected automatically based on `kReleaseMode`.

**Snackbars:** Always use `LwpSnackbar` — never the base Flutter `SnackBar` or `animated_snack_bar` directly.
```dart
LwpSnackbar.showSuccess(context, 'Suksesvol gestoor');
LwpSnackbar.showError(context, 'Iets het verkeerd gegaan');
```

**Theming:** Always use `Theme.of(context)` or `LightColors`/`DarkColors` constants. Never hardcode colours. AppBars and buttons use `elevation: 0`. All interactive elements use `BorderRadius.circular(24.0)`.

**Card UI:** Border radius `24.0` everywhere. For label-value rows, fixed label width `130.0` with `maxLines: 1, overflow: TextOverflow.ellipsis`. Separate sections with `Divider(height: 32)`.

**Dashboard pattern:** Hero section (latest content) → 2-column grid of icon-based cards. Show a themed loading placeholder while fetching.

**Typing:** Always use explicit types. Avoid `dynamic`. Use sealed classes / enums for state representation. Models must be immutable.

**Commit messages:** `feature:`, `refactor:`, `chore:`, `fix:` prefixes — e.g. `feature: add sermon details view`.

## Theme Reference

| Token | Light | Dark |
|---|---|---|
| Primary | `#11181C` Deep Black | `#F2C94C` Gold |
| Background | `#FAFAFA` Off-white | `#121212` Deep Dark |
| Surface / Bottom Nav | — | `#1E1E1E` Charcoal |

Auth screens use a 2:3 split (Hero image top, form bottom) with a `LinearGradient` fade into the scaffold background. Multi-step forms show step progress ("Stap 1 van 3") and navigate between steps without popping the route until the first step.
