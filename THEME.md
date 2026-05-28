# LW App Theme & Branding Guidelines

## Core Brand Identity
The application branding is derived from the official logo, featuring a high-contrast, modern aesthetic.

### Color Palette
- **Primary (Light):** `#11181C` (Deep Black)
- **Primary (Dark) / Accent:** `#2E86C1` (Blue)
- **Background (Light):** `#FAFAFA` (Off-white)
- **Background (Dark):** `#121212` (Deep Dark)
- **Surface (Dark):** `#1E1E1E` (Charcoal - used for Cards and Bottom Navigation)
- **Outline (Light Cards):** `#E4E7EA` (Subtle card separation)

Use `Theme.of(context)`, `LightColors`/`DarkColors`, `LwpRadii`, and `LwpSpacing` from `lib/Themes/` instead of hardcoding colours, spacing, border radii, card borders, or elevation values. Raw hex colours, ad-hoc `Colors.grey`, numeric radii, and one-off spacing should only be used when a component has a clear, documented reason to differ from the app standard.

## UI Component Standards

### 1. Layout Patterns: The "Split Screen" (Reference: Auth Screens)
- **Structure:** Divide screens into a 2:3 ratio (Top:Bottom).
- **Top Section (Hero):** Use a `Hero` widget with a consistent tag (e.g., `auth_top_section`) containing a high-quality brand image or logo.
- **Gradient Overlay:** Apply a `LinearGradient` (Transparent -> `scaffoldBackgroundColor`) over the Hero section to ensure a seamless transition into the form/content area.
- **Bottom Section:** Use a `SingleChildScrollView` with standard padding (`horizontal: 24.0, vertical: 32.0`) for forms and content.

### 2. Multi-Step Wizards (Reference: Registration Flow)
- **Usage:** For complex forms or onboarding (3+ fields), use a multi-step wizard to reduce cognitive load.
- **Progress:** Clearly indicate the current step and total steps (e.g., "Stap 1 van 3").
- **Navigation:** Provide "Next" and "Previous" actions. Integrated "Back" buttons should move to the previous step rather than popping the route, until the first step is reached.
- **Visuals:** Maintain the "Split Screen" layout across all steps for visual continuity. Use `Hero` tags to keep the background/header stable during step transitions.

### 3. AppBars & Navigation
- **Elevation:** Always `0` for a flat aesthetic.
- **Integrated Navigation:** For secondary screens (like Registration), prefer an integrated "Close" or "Back" `IconButton` adjacent to the section title rather than a floating or standard AppBar back button. This maintains visual focus on the content.

### 3. Cards, Buttons & Inputs
- **Cards:** Inherit `Theme.of(context).cardTheme` so the shared flat elevation, `LwpRadii.lg` radius, and light-mode outline stay consistent. Do not override `Card.shape`, `elevation`, or borders locally unless the component intentionally differs from the app standard.
- **Shape:** Use `LwpRadii` tokens for interactive elements. Use `StadiumBorder` or `LwpRadii.pill` for chips and pill-like controls.
- **Buttons:** Elevation `0`. Light Mode uses Deep Black background; Dark Mode uses Blue.
- **Inputs:** `filled: true` with no idle border. A `2.0` width brand-colour border appears only on focus. Use meaningful icons (`prefixIcon`) to guide the user.
- **Bottom Sheets:** Use `LwpBottomSheet`/`LwpSheetHandle` where practical so rounded tops, drag handles, padding, and close affordances remain consistent.

## UX & Language Standards
- **Afrikaans UI:** ALL user-facing text must be in Afrikaans.
- **Contextual Feedback:** Always use `LwpSnackbar` (built on `animated_snack_bar`) for success, error, or info feedback. Ensure the `LwpSnackbar` theme matches the current system brightness (Blue for Dark, Black for Light).
- **Smooth Transitions:** Utilize `Hero` animations and `MaterialPageRoute` transitions to keep the application feeling fluid and interconnected.
