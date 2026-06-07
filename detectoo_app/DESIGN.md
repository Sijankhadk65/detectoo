# DESIGN.md

UI/design guidelines for the Detectoo app — "The Digital Curator for your Garden."
The app should feel like a gardening journal run by a medical clinic: calm,
intelligent, and caring. Quiet confidence over loud or gamified.

All tokens live in `lib/src/theme/` — use them rather than hardcoding values:
- `detectoo_colors.dart` — `DetectooColors`, `DetectooRadii`, `DetectooShadows`
- `detectoo_text_styles.dart` — `DetectooText`
- `detectoo_theme.dart` — `detectooTheme()` (wired in `app.dart`)

## Colour

Detectoo is a **monochrome-green system with a single terracotta accent**.
There are no secondary brand hues — restraint is the point.

- **Canvas cream `#EEF4DE`** (`DetectooColors.canvasCream`) is the signature app
  background. Preserve it; do not use white or grey as the screen background.
- **Brand greens** (`green900`→`green050`): text, headings, primary buttons
  (`green600`), progress/health fills (`green500`), chip fills (`green100`).
- **Terracotta** (`DetectooColors.terracotta` `#D84A1E`): the single accent —
  eyebrows, AI/scanning states, alerts, the SCAN button and shutter. Use
  sparingly for attention.
- **Dark forest** (`surfaceDark`/`surfaceDarkDeep`): the only gradient allowed,
  used for vitals/stat cards, image frames, and dark headers.
- **Semantic**: success = `green500`, warning = `warning` (`#D98B1E`),
  danger = terracotta.
- No amber palette, no blue/purple, no rainbow or mesh gradients.

## Typography

Two Google Fonts via the `google_fonts` package (see `DetectooText`):
- **Plus Jakarta Sans** — display/headlines, extrabold (w800) with tight
  tracking and leading. Used for `display`, `h1`, `h2`, `h3`, and eyebrows.
- **Nunito** — body copy, 400/500/700. Used for `body`, `bodyStrong`, `small`.

The serif (Georgia) of the old design is gone. The universal header structure is
**eyebrow → H1 → body** (`EyebrowLabel` + `DetectooText.h1` + `DetectooText.body`).
Statement titles use Title Case with a trailing period ("…for your Garden.").

## Voice

Warm, confident, botanical — the product is a **curator/doctor**, never a tool.
The user is a **"Plant Parent"**. Use clinical-botanical vocabulary (diagnosis,
specimen, protocol, vitals, confidence score). Short, declarative sentences;
em dashes welcome. **British spelling** (analyse, personalise, discolouration).
**No emoji** anywhere — icons are Material glyphs.

## Components

- **Buttons** (`DetectooButton`): pill-shaped (999px). `primary` (green-600),
  `accent` (terracotta), `ghost` (outlined). Press scales to 0.97 — no hue shift.
- **Cards** (`DetectooCard`): three archetypes via `variant` —
  `white` (elevated, soft green shadow, 20px radius), `cream` (quiet container,
  no shadow), `dark` (forest surface, white text, green progress).
- **Chips** (`StatusChip`): quiet green pill by default; `accent` for the
  uppercase tracked terracotta badge (e.g. "2 PLANS").
- **Eyebrow** (`EyebrowLabel`): UPPERCASE, tracked, terracotta (or green).
- **Icon tiles** (`IconBadge`): green-100 tile + green-600 glyph by default.
- **Bottom nav** (`BottomNavBar`): a floating white capsule (24px radius, soft
  shadow, 8px off the bottom) with an active dark-green pill tab and a raised
  terracotta SCAN button at the centre.

## Layout & elevation

- 24px screen gutters; 16–20px card padding; ~16px vertical rhythm.
- Radii: buttons/chips pill, cards 16–20px, inputs 12px, images 12–16px.
- Shadows are soft and low-opacity, green-tinted (`DetectooShadows`). No glow.
- Borders: hairline `borderSoft` where needed, or shadow-only on elevated cards.

## Motion

Fades and gentle slides only — no bounces, elastic, or rotations. Easing
`Curves.easeOut`, durations 160–400ms. Progress bars use terracotta for AI /
scanning states and green-500 for health/vitals.

## Theme

Light theme only (cream canvas). Material 3.
