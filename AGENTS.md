# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter app for Lewende Woord Paarl. Application code lives in `lib/`:

- `lib/Blocs/`: feature BLoCs, events, and states, grouped by feature such as `Auth`, `Events`, and `Notes`.
- `lib/Models/`: typed data models and enums.
- `lib/Screens/`: route and screen-level UI.
- `lib/Services/`: Supabase, API, auth, storage, and external integration access.
- `lib/Widgets/`: reusable UI components.
- `lib/Utils/`: environment, formatting, Cloudinary, and map helpers.
- `lib/Themes/`: app theme definitions.

Tests are in `test/`. Static assets are in `assets/`. Platform projects are under `android/`, `ios/`, and `web/`.

## Build, Test, and Development Commands

- `flutter pub get`: install Dart and Flutter dependencies.
- `flutter run --dart-define-from-file=.env.development`: run locally with development configuration.
- `flutter analyze`: run Dart analyzer and project lints.
- `flutter test`: run widget and unit tests.
- `flutter build apk`: build an Android APK.
- `flutter build ios`: build the iOS app from macOS with Xcode configured.

Keep `.env.development` and `.env.production` local, but do not commit secrets.

## Coding Style & Naming Conventions

Use `flutter_lints` from `analysis_options.yaml`. Format Dart with `dart format .` before broad changes. Use `snake_case.dart` for filenames, `UpperCamelCase` for classes/enums, and `lowerCamelCase` for variables/methods.

Keep business logic out of widgets. UI dispatches BLoC events and renders states; BLoCs call `Services`; `Services` handle Supabase or external APIs. Use explicit types and avoid `dynamic` unless required. UI-facing text should remain in Afrikaans; code identifiers stay English.

## UI Standards & Design Tokens

Always use the project design system instead of hardcoding visual values. Use `Theme.of(context)`, `LightColors`/`DarkColors`, `LwpRadii`, and `LwpSpacing` from `lib/Themes/` for colours, radii, spacing, card shape, and component styling. Do not introduce raw hex colours, ad-hoc `Colors.grey`, numeric border radii, custom card outlines, or one-off spacing unless there is a clear component-specific reason.

Cards should inherit `Theme.of(context).cardTheme` so the shared flat elevation, 24px radius, and light-mode outline stay consistent. Chips and pill-like controls should use `StadiumBorder` or `LwpRadii.pill`. Bottom sheets should use `LwpBottomSheet`/`LwpSheetHandle` where practical. Prefer existing wrappers such as `LwpSnackbar`, `LwpError`, `LwpEmpty`, `LwpLoader`, and themed components instead of direct package or base Flutter equivalents when the project already has an abstraction.

## Testing Guidelines

Use `flutter_test`. Name test files with `_test.dart` under `test/`. Add widget tests for screens/widgets and unit tests for BLoC/service logic where practical. Run `flutter test` and `flutter analyze` before opening a PR.

## Commit & Pull Request Guidelines

Recent commits use short, imperative messages with prefixes such as `feature:`, `refactor:`, and `chore:`. Follow that pattern, for example `feature: add sermon details view`.

Pull requests should include a summary, linked issue or task when available, test results, and screenshots or recordings for UI changes. Note environment, Supabase, or asset changes explicitly.

## Security & Configuration Tips

Do not hardcode secrets or environment-specific URLs. Access configuration through `lib/Utils/environment.dart`.
