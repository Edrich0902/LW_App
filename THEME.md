# LW App Theme & Branding Guidelines

## Core Brand Identity
The application branding is derived from the official logo, featuring a high-contrast, modern aesthetic.

### Color Palette
- **Primary (Light):** `#11181C` (Deep Black)
- **Primary (Dark) / Accent:** `#F2C94C` (Vibrant Gold)
- **Background (Light):** `#FAFAFA` (Off-white)
- **Background (Dark):** `#121212` (Deep Dark)
- **Surface (Dark):** `#1E1E1E` (Charcoal - used for Cards and Bottom Navigation)

## UI Component Standards

### 1. AppBars (Flat & Seamless)
- **Elevation:** Always `0`.
- **Background:** Match the `scaffoldBackgroundColor`.
- **Title:** Use `Theme.of(context).primaryColor` to ensure visibility against the background.
- **Goal:** Create a seamless transition from the status bar to the content.

### 2. Buttons
- **Shape:** `BorderRadius.circular(24.0)`.
- **Elevation:** `0` (Flat design).
- **Padding:** `EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)`.
- **Light Mode:** Deep Black background with White text.
- **Dark Mode:** Gold background with Black text for maximum readability.

### 3. Inputs (Filled & Borderless)
- **Style:** `filled: true` with no visible border in the idle state.
- **Focus:** A `2.0` width border in brand Gold appears ONLY when focused.
- **Fill Color:** Light gray (`#EEEEEE`) in Light Mode, dark gray (`#2A2A2A`) in Dark Mode.
- **Labels:** Must use brand colors (Deep Black/Gold) via `labelStyle` and `floatingLabelStyle`.

### 4. Navigation (GNav)
- **Background:** Charcoal (`#1E1E1E`) in Dark Mode to reduce glare.
- **Active State:** Subtle Gold tint background with solid Gold icon/text.
- **Overflow Prevention:** Keep `gap` at `4` and horizontal `padding` at `4-10` to accommodate longer Afrikaans titles like "Meer Oor Ons".

## Global Constraints
- **NO Unapproved Text Changes:** Never modify user-facing labels, titles, or messages (e.g., menu items) without explicit user consultation.
- **AFRIKAANS UI:** All user-facing text must remain in Afrikaans.
- **Consistency:** Use `Theme.of(context)` values rather than hardcoded colors.
