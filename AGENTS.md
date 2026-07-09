# LW App — Agent Guide

Flutter mobile app for **Lewende Woord Paarl** — sermons, notes, events, Bible, groups, prayer, pastoral blog. Platform context: see `../AGENTS.md`. Roadmap: `../roadmap.md`.

**UI language:** Afrikaans for all user-facing text. Code identifiers in English.

**Stack:** Flutter, BLoC, Supabase, Cloudinary, `flutter_dotenv`.

## Project Structure

- `lib/Screens/` — route-level UI (dispatches BLoC events, renders states only)
- `lib/Blocs/` — `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- `lib/Services/` — all Supabase and external API calls
- `lib/Models/` — immutable typed models
- `lib/Widgets/` — reusable UI (`Lwp*` prefix)
- `lib/Utils/` — `environment.dart`, Cloudinary, formatters
- `lib/Themes/` — `AppTheme`, `LightColors`, `DarkColors`, `LwpRadii`, `LwpSpacing`

**Data flow:** `UI → BLoC → Service → Supabase`. Never call Supabase from widgets.

`lib/main.dart` bootstraps Supabase, Cloudinary, dotenv, and `MultiBlocProvider`.

Navigation: bottom tabs in `lib/Screens/Container/container.dart` — Tuis, Kalender, Bybel, Meer Oor Ons, Skakel In.

## Commands

```bash
flutter pub get
flutter run --dart-define-from-file=.env.development
flutter analyze                    # run after every code change
dart format .
flutter test
flutter build apk
flutter build ios                  # macOS + Xcode
```

## Environment

Read config via `lib/Utils/environment.dart`. Never hardcode secrets or URLs.
`.env.development` / `.env.production` are bundled as assets in `pubspec.yaml`.

## UI & Theming

Full branding reference: `THEME.md`.

- Use `Theme.of(context)`, `LightColors`/`DarkColors`, `LwpRadii`, `LwpSpacing` — no raw hex, ad-hoc `Colors.grey`, or one-off radii/spacing
- Cards inherit `Theme.of(context).cardTheme` (flat elevation, 24px radius, light outline)
- AppBars and buttons: `elevation: 0`
- Snackbars: always `LwpSnackbar` — never base `SnackBar` or `animated_snack_bar` directly
- Bottom sheets: `LwpBottomSheet` / `LwpSheetHandle`
- Chips/pills: `StadiumBorder` or `LwpRadii.pill`
- Popup menus: inherit `AppTheme.popupMenuTheme` — no per-instance colour/shape; always `Row(Icon, SizedBox, Text)` in items; destructive actions use red + `Icons.delete_outline`
- Dashboard: hero section → 2-column icon grid; themed loading placeholders
- Auth: 2:3 split (hero image + form), gradient fade, multi-step wizards with "Stap X van Y"

### Component-first rule

Check `lib/Widgets/` for `Lwp*` abstractions before using raw Flutter widgets (`Image`, `CircleAvatar`, `SnackBar`, etc.).

## Conventions

- Files: `snake_case.dart`; classes: `UpperCamelCase`; members: `lowerCamelCase`
- Explicit types; avoid `dynamic`; immutable models; sealed classes/enums for states
- `share_plus`: always pass `sharePositionOrigin` (iOS crashes without it)
- Format technical values for display (e.g. `super_admin` → `Super Admin`)
- Card detail rows: label width `130.0`, `maxLines: 1`, `overflow: TextOverflow.ellipsis`; section dividers `Divider(height: 32)`

## Groups & Feed

Full contract and file map: `docs/groups-feed-handoff.md`.

- Group feed is full-screen (not inline in group detail)
- Leader-authored posts with member reactions; not a chat
- Pin/unpin via popup menu ("Speld"/"Onthef"); pinned posts badge "Vasgespeld"
- Feed uses `GroupDetailBloc` (reuses group-detail fetch flow)

## Feature Docs

| Doc | When to read |
|-----|--------------|
| `docs/groups-feed-handoff.md` | Groups 2.0 feed work |
| `THEME.md` | Any UI change |
| `docs/i18n-plan.md` | Future localization |
| `docs/ui-consistency-plan.md` | Design token rollout (in progress) |
| `lib/Screens/Bible/BIBLE_IMPLEMENTATION.md` | Bible feature |
| `you_version_integration.md` | YouVersion API notes |

Delivered plans are in `docs/archive/`.

## Testing

`flutter test` + `flutter analyze` before PR. Tests in `test/` named `*_test.dart`.
