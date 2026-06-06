# LW_App Internationalisation (i18n) Plan
## English & Afrikaans Support

---

## Current State

The app is entirely hardcoded in Afrikaans. Approximately 263 `Text()` widgets and ~310 user-facing strings exist across 42 screen files — none externalized. However, a partial foundation is already in place.

### What already exists

- `flutter_localizations` is a dependency in `pubspec.yaml`
- `intl ^0.20.2` is installed (used only for date formatting today)
- `supportedLocales: [Locale('en'), Locale('af')]` is declared in `MaterialApp`
- `GlobalMaterialLocalizations.delegate` is wired up — Material UI components (date pickers, OK/Cancel, etc.) already respond to system locale

### What is missing

- No app-level string translation system (no `.arb` files, no translation package)
- No locale preference stored (unlike Theme, which uses `SharedPreferences` via `ThemeBloc`)
- No language switcher in Settings UI
- No `preferred_language` column in the Supabase `profiles` table

---

## Recommended Approach: Flutter Official ARB + `gen-l10n`

Use the **official Flutter localization toolchain** (`flutter gen-l10n` with `.arb` files) rather than third-party packages like `easy_localization`. Rationale:

- `flutter_localizations` and `intl` are already installed — no new dependencies needed
- Generates a fully type-safe `AppLocalizations` accessor class — compile-time safety, no string key typos
- First-class IDE support (autocomplete, refactoring)
- Aligns cleanly with the existing BLoC architecture

---

## Architecture

### 1. Translation Files

Create `lib/l10n/` directory with two `.arb` files:

```
lib/l10n/
  app_af.arb    ← Afrikaans (primary — migrate all existing hardcoded strings here)
  app_en.arb    ← English translations
```

**Sample `app_af.arb`:**
```json
{
  "@@locale": "af",
  "appTitle": "Lewende Woord Paarl",
  "welcome": "Welkom Terug",
  "signInSubtitle": "Teken in om voort te gaan",
  "signIn": "Teken In",
  "email": "E-pos",
  "password": "Wagwoord",
  "forgotPassword": "Wagwoord vergeet?",
  "noAccount": "Het jy nie 'n rekening nie? Registreer hier",
  "signInSuccess": "Intekening suksesvol",
  "signInFailed": "Intekening het misluk. Kontroleer asseblief jou besonderhede.",
  "navHome": "Tuis",
  "navCalendar": "Kalender",
  "navBible": "Bybel",
  "navMoreInfo": "Meer Oor Ons",
  "navConnect": "Skakel In"
}
```

**Sample `app_en.arb`:**
```json
{
  "@@locale": "en",
  "appTitle": "Living Word Paarl",
  "welcome": "Welcome Back",
  "signInSubtitle": "Sign in to continue",
  "signIn": "Sign In",
  "email": "Email",
  "password": "Password",
  "forgotPassword": "Forgot password?",
  "noAccount": "Don't have an account? Register here",
  "signInSuccess": "Sign-in successful",
  "signInFailed": "Sign-in failed. Please check your details.",
  "navHome": "Home",
  "navCalendar": "Calendar",
  "navBible": "Bible",
  "navMoreInfo": "More About Us",
  "navConnect": "Connect"
}
```

### 2. `LocaleBloc`

New BLoC following the exact same pattern as `ThemeBloc`. Stores locale preference in `SharedPreferences` and optionally syncs with Supabase.

Create:
```
lib/Blocs/Locale/
  locale_bloc.dart
  locale_event.dart
  locale_state.dart
```

**`locale_state.dart`:**
```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale locale;
  const LocaleState(this.locale);
  @override
  List<Object> get props => [locale];
}
```

**`locale_event.dart`:**
```dart
abstract class LocaleEvent {}

class InitLocaleEvent extends LocaleEvent {}

class UpdateLocaleEvent extends LocaleEvent {
  final Locale locale;
  const UpdateLocaleEvent(this.locale);
}
```

**`locale_bloc.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'user_locale_preference';

  LocaleBloc() : super(const LocaleState(Locale('af'))) {
    on<InitLocaleEvent>(_onInit);
    on<UpdateLocaleEvent>(_onUpdate);
  }

  Future<void> _onInit(InitLocaleEvent event, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localeKey);
    emit(LocaleState(Locale(stored ?? 'af')));
  }

  Future<void> _onUpdate(UpdateLocaleEvent event, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, event.locale.languageCode);
    emit(LocaleState(event.locale));
    // Phase 4: also sync to Supabase profiles table here
  }
}
```

### 3. `pubspec.yaml` and `l10n.yaml` Changes

Add `generate: true` under the `flutter:` key in `pubspec.yaml`:

```yaml
flutter:
  generate: true   # enables gen-l10n
  uses-material-design: true
  assets:
    ...
```

Create `l10n.yaml` in the project root:

```yaml
arb-dir: lib/l10n
template-arb-file: app_af.arb
output-localization-file: app_localizations.dart
```

Run `flutter gen-l10n` (or `flutter pub get` with `generate: true`) to produce the `AppLocalizations` class in `.dart_tool/flutter_gen/gen_l10n/`.

### 4. `main.dart` Changes

Register `LocaleBloc` in `MultiBlocProvider` and wire `MaterialApp.locale` + `AppLocalizations.delegate`:

```dart
// In MultiBlocProvider providers list, add:
BlocProvider<LocaleBloc>(
  create: (context) => LocaleBloc()..add(InitLocaleEvent()),
),

// Wrap the existing BlocBuilder<ThemeBloc> with BlocBuilder<LocaleBloc>:
BlocBuilder<LocaleBloc, LocaleState>(
  builder: (context, localeState) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Lewende Woord Paarl',
          locale: localeState.locale,                    // ← NEW
          localizationsDelegates: const [
            AppLocalizations.delegate,                   // ← NEW (generated)
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales, // ← from generated class
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          home: const LwpSplashScreen(),
        );
      },
    );
  },
),
```

### 5. Convenience Extension

Add to `lib/Extensions/context_l10n.dart` (or equivalent extensions file):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

This shortens usage in screens from `AppLocalizations.of(context)!.welcome` to `context.l10n.welcome`.

### 6. Usage in Screens

```dart
// Before
Text("Welkom Terug")

// After
Text(context.l10n.welcome)
```

Snackbar messages (currently in BLoC event handlers or screen callbacks):
```dart
// Before
LwpSnackbar.showError(context, "Intekening het misluk. Kontroleer asseblief jou besonderhede.");

// After
LwpSnackbar.showError(context, context.l10n.signInFailed);
```

### 7. Language Switcher in Settings

Add to `lib/Screens/Settings/settings.dart`, mirroring the existing theme toggle pattern:

```dart
BlocBuilder<LocaleBloc, LocaleState>(
  builder: (context, state) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'af', label: Text('Afrikaans')),
        ButtonSegment(value: 'en', label: Text('English')),
      ],
      selected: {state.locale.languageCode},
      onSelectionChanged: (selected) {
        context.read<LocaleBloc>().add(
          UpdateLocaleEvent(Locale(selected.first)),
        );
      },
    );
  },
)
```

### 8. Supabase Schema Migration

```sql
ALTER TABLE profiles
ADD COLUMN preferred_language VARCHAR(10) DEFAULT NULL;
```

- `NULL` = not yet set; fall back to `SharedPreferences` value or default `'af'`
- Populated on first explicit language selection
- Read on login and used to seed `LocaleBloc` (overrides local pref if present)

Update `lib/Models/User/user_profile.dart`:

```dart
class UserProfile extends Equatable {
  // ... existing fields ...
  final String? preferredLanguage;  // ← ADD

  // Update fromJson factory:
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // ... existing fields ...
      preferredLanguage: json['preferred_language'] as String?,
    );
  }
}
```

In `LocaleBloc`, after login resolves and `UserProfile` is available, emit the server-stored locale to override the local preference:

```dart
// In AuthBloc or UserBloc, after profile loads:
if (profile.preferredLanguage != null) {
  context.read<LocaleBloc>().add(
    UpdateLocaleEvent(Locale(profile.preferredLanguage!)),
  );
}
```

---

## String Migration Scope

| Area | Key Files | Approx. Strings |
|------|-----------|-----------------|
| Auth | login, register, forgot_password, reset_password, email_confirm | ~55 |
| Navigation | container (bottom tab labels) | ~10 |
| Dashboard + Home | dashboard, home, sermon cards, VOTD | ~30 |
| Profile + Settings | profile, profile_edit, settings | ~25 |
| Calendar + Events | calendar, event detail | ~20 |
| Connect | connect, 6× group screens, service group screens | ~50 |
| Bible | bible, version selector, chapters, saved verses | ~35 |
| Prayer requests | prayer list, my prayers | ~20 |
| More About Us | more_info, roleplayers | ~15 |
| Shared widgets | LwpSnackbar messages, LwpLoader, LwpError messages | ~50 |
| **Total** | **~42 screen files + shared widgets** | **~310 strings** |

---

## Implementation Phases

### Phase 1 — Infrastructure (no visible user change)

1. Add `generate: true` to `pubspec.yaml` under `flutter:`
2. Create `l10n.yaml` in the project root
3. Create `lib/l10n/app_af.arb` — add all Afrikaans strings (use existing hardcoded text as-is)
4. Run `flutter gen-l10n` to generate `AppLocalizations`
5. Create `LocaleBloc` (state, event, bloc) following `ThemeBloc` pattern
6. Register `LocaleBloc` in `MultiBlocProvider` in `main.dart` with `InitLocaleEvent`
7. Wire `AppLocalizations.delegate` and `locale: localeState.locale` into `MaterialApp`
8. Add `ContextL10n` extension

**Goal:** App still looks and behaves identically. Infrastructure is in place.

### Phase 2 — Afrikaans string migration

9. Screen by screen, replace every hardcoded Afrikaans string with `context.l10n.key`
10. Migration is mechanical and non-breaking — Afrikaans `.arb` is the source of truth, so the app remains visually unchanged
11. Suggested order: Auth → Container/Navigation → Settings → Dashboard → Profile → Connect → Bible → Calendar → Prayer → MoreInfo → Shared widgets

**Goal:** All strings externalized; app still fully in Afrikaans.

### Phase 3 — English translations + language switcher

12. Create `lib/l10n/app_en.arb` with English translations for every key from `app_af.arb`
13. Add language switcher `SegmentedButton` to Settings screen
14. Test every screen in both languages — check for layout issues caused by longer English strings

**Goal:** User can switch between Afrikaans and English in Settings.

### Phase 4 — Supabase sync (recommended for multi-device users)

15. Write and apply Supabase migration: `ALTER TABLE profiles ADD COLUMN preferred_language VARCHAR(10)`
16. Update `UserProfile` model to include `preferredLanguage`
17. In `LocaleBloc` / auth flow: read `preferred_language` from profile on login and emit as locale
18. In `LocaleBloc.UpdateLocaleEvent`: write updated preference back to Supabase profile

**Goal:** Language preference survives app reinstall and syncs across devices.

---

## Effort Estimate

| Phase | Effort |
|-------|--------|
| Phase 1 — Infrastructure | ~2–3 hours |
| Phase 2 — Afrikaans migration (42 screens) | ~6–8 hours |
| Phase 3 — English translations + switcher UI | ~4–5 hours |
| Phase 4 — Supabase sync | ~2–3 hours |
| **Total** | **~14–19 hours** |

---

## Key Decisions

- **Default language:** Afrikaans. All existing strings are Afrikaans; the congregation is primarily Afrikaans-speaking. English is opt-in via Settings.
- **Locale persistence:** SharedPreferences (local, Phase 1–3) + Supabase profile column (multi-device, Phase 4).
- **No new dependencies required** for Phases 1–3: `flutter_localizations` and `intl` are already in `pubspec.yaml`.
- **String key naming convention:** camelCase, descriptive, scoped by feature where needed (e.g., `authSignIn`, `navHome`, `profileLoadError`). Avoid generic keys like `error` or `ok` — prefer `signInError`, `deleteConfirmOk`.
- **Plurals and interpolation:** Use ARB `{count}` placeholders and `plural` metadata where strings contain counts (e.g., "1 lid / 3 lede"). The `intl` package handles this natively.
