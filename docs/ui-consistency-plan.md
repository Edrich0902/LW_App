# UI Consistency & Polish Plan

Status: in progress
Owner: started by Edrich + Claude
Goal: bring the mobile app's visual language in line with the consistency we achieved
in LW_Portal_2.0 — single source of truth for radii, spacing, elevation, and colour,
applied uniformly across screens, widgets, cards, and bottom sheets.

This document is the reference for the work. It is written so another developer can
pick up any phase without prior context. Each phase is independent and ships on its own.

---

## 1. Why

The design values are *documented* in `CLAUDE.md` (radius 24, 8pt spacing, theme colours)
but they are hand-typed at every call site. With no shared constants, values drift:
the same button appears with two radii, cards float in one list and lie flat in the next,
and the brand colour is re-typed as a raw hex in a dozen files. The fix is to introduce
**design tokens** and then mechanically route every call site through them.

### Audit findings (snapshot at start)

Counts gathered via grep over `lib/`:

- **Border radius**: `24.0` dominant (~49) but also `12` (11), `16` (16), `20` (4),
  `8` (3), `2` (3), `32` (2). Same component types use different radii.
- **Card elevation**: `cardTheme` declares `elevation: 4`, but ~8 card widgets override
  to `elevation: 0` (`LwpEvent`, `LwpGroupCard`, `DashboardVotdCard`,
  `roleplayer_grid_card`, `lwp_group_bottom_sheet`). `DashboardGridCard` and
  `PrayerRequestCard` use the default and float. Result: home grid casts shadows,
  event/group lists don't.
- **Colour drift**: `Color(0xFF11181C)` hand-typed 11x instead of `LightColors.primary`;
  other raw hexes (`023059`, `1E1E1E`, `4D4B4B`) recur. `Colors.grey` used 33x with no
  shared "muted" token.
- **Doc/code mismatch**: `CLAUDE.md` theme table says dark Primary = Gold `#F2C94C`,
  but `custom_theme.dart` sets dark primary to blue `#2E86C1`. One is wrong.
- **Bottom sheets**: `LwpEvent` builds a sheet inline; groups use a dedicated
  `LwpGroupBottomSheet`. Each re-implements rounded top + drag handle + close, with
  radii varying 24/32 and drag handles re-declared with `Radius.circular(2)` in 3 files.
- **Repeated boilerplate**: `dashboard.dart` repeats a `Container(height:180, radius 24)`
  loading/error placeholder 4x; every screen re-sets AppBar `elevation: 0` though the
  theme already does; ~25 hardcoded `fontSize:` values bypass the type scale;
  `LwpEmpty`/`LwpLoader` are `StatefulWidget` with empty `initState`; `LwpEmpty` leaks an
  English fallback string `"No content to display"`.

---

## 2. Target design tokens

New file: `lib/Themes/lwp_tokens.dart`.

### Radii — `LwpRadii`

| Token | Value | Usage |
|---|---|---|
| `handle` | 2.0 | bottom-sheet drag handles |
| `sm` | 12.0 | chips, pills' fallback, inline note containers, inner thumbnails |
| `md` | 16.0 | hero / larger inner media |
| `lg` | 24.0 | cards, sheets, buttons, inputs, dialogs (the default) |
| `pill` | 999.0 | fully-rounded badges (use `StadiumBorder` where possible) |

Mapping decisions:
- Inner image clips currently at `16` → move to `sm` (12) so they nest correctly inside
  a 24 card with 12 padding. (Hero/banner media that fills width stays `md`.)
- The "Voeg by Kalender" button radius `16` → `lg` (24) to match the themed buttons.
- Category pill `20` → `pill` (StadiumBorder).
- Sheet tops `32` → `lg` (24).

### Spacing — `LwpSpacing`

8pt-based scale. The codebase is already ~90% on this grid.

| Token | Value |
|---|---|
| `xxs` | 4.0 |
| `xs` | 8.0 |
| `sm` | 12.0 |
| `md` | 16.0 |
| `lg` | 24.0 |
| `xl` | 32.0 |
| `xxl` | 48.0 |

**Scope decision (discuss):** we do **not** do a blanket migration of all ~150
`SizedBox`/`EdgeInsets` to tokens — that is high churn for low visual gain since spacing
is mostly already consistent. Instead: introduce the scale, snap the few outliers
(`6`, `10`, `14`, `20`, `28`) to the nearest token, and use tokens in all new/touched code.

### Colours

Complete the existing `LightColors`/`DarkColors` classes rather than adding a third system.
- Add a `muted` constant (replaces ad-hoc `Colors.grey`; prefer `theme.hintColor` where a
  context is available).
- Route raw `Color(0xFF11181C)` etc. through the named constants.
- **Decision required:** dark primary — gold `#F2C94C` (per CLAUDE.md) or blue `#2E86C1`
  (per code). Whichever we pick, update the other source so they agree.

---

## 3. Phased implementation

Phases are ordered for lowest risk and earliest visible payoff. Run
`flutter analyze` after each phase; `dart format .` before committing.

### Phase 1 — Tokens (foundation)
- Add `lib/Themes/lwp_tokens.dart` with `LwpRadii` and `LwpSpacing`.
- Extend `LightColors`/`DarkColors` with `muted`.
- No call sites changed yet. Pure addition; safe.

### Phase 2 — Border radii
- Replace every `BorderRadius.circular(n)` / `Radius.circular(n)` with the matching
  `LwpRadii` token per the mapping table.
- Files: `bible.dart`, `saved_verses.dart`, `course_detail.dart`, `roleplayer_detail.dart`,
  `social_media.dart`, `tithes_offerings.dart`, `upcoming_event_detail.dart`,
  `user_announcements.dart`, `compare_translations_sheet.dart`, `connect_hero.dart`,
  `dashboard_hero_sermon.dart`, `dashboard_votd_card.dart`, `lwp_group_bottom_sheet.dart`,
  `lwp_group_card.dart`, `lwp_event.dart`, `prayer_request_card.dart`, plus theme file.
- Visual QA: cards, chips, sheets, buttons, inputs.

### Phase 3 — Card elevation
- Set `cardTheme.elevation: 0` (flat) in both light and dark themes in `custom_theme.dart`.
  (Flat chosen because the majority of widgets already override to 0.)
- Remove the per-widget `elevation: 0` overrides on `Card`s now made redundant.
- Keep deliberate non-card elevations (e.g. floating menus) as-is.
- Visual QA: dashboard grid + event/group lists should now match.

### Phase 4 — Colour drift
- Resolve the dark-primary decision and align `custom_theme.dart` + `CLAUDE.md`.
- Replace raw hex literals outside the theme with `LightColors`/`DarkColors` constants.
- Replace ad-hoc `Colors.grey` with `theme.hintColor` / `Lwp... .muted`.
- Leave semantic status colours (`Colors.green/red/orange` for prayer status) alone.

### Phase 5 — Shared bottom sheet shell
- Add `lib/Widgets/LwpBottomSheet/lwp_bottom_sheet.dart`: rounded top (`LwpRadii.lg`),
  drag handle (`LwpRadii.handle`), optional close button, takes a child + optional header
  media. Use `showModalBottomSheet` with transparent background as today.
- Refactor `LwpEvent._showEventDetails` and `LwpGroupBottomSheet` to use it.
- Visual QA: both sheets, scroll behaviour, close button, share/calendar actions.

### Phase 6 — Smaller boilerplate
- Extract `DashboardPlaceholder` widget for the repeated loading/error container in
  `dashboard.dart` (height 180, radius `lg`).
- Drop redundant `elevation: 0` on AppBars (theme already sets it).
- Convert `LwpEmpty` and `LwpLoader` from `StatefulWidget` to `StatelessWidget`.
- Fix `LwpEmpty` English fallback → Afrikaans (`"Geen inhoud om te wys nie"`).
- Replace hardcoded `fontSize:` with `textTheme` styles where a clean mapping exists.
- Final `flutter analyze` + `dart format .`.

---

## 4. Conventions to keep (already correct)

- BLoC-only state flow; no Supabase in widgets.
- `LwpSnackbar` for all snackbars.
- `share_plus` always passes `sharePositionOrigin`.
- Afrikaans UI text, English identifiers.
- All interactive elements rounded; AppBars/buttons `elevation: 0`.

## 5. Decisions (resolved 2026-05-29)

1. **Dark primary colour**: **Blue `#2E86C1`** (keep code). Update `CLAUDE.md` theme table
   to say blue so docs match code.
2. **Flat vs floating cards**: **Flat** (`cardTheme.elevation: 0`).
3. **Spacing migration scope**: **Opportunistic** — add scale, snap outliers, use in
   touched code; no blanket migration.
