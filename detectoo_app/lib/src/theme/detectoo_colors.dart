import 'package:flutter/material.dart';

/// Detectoo brand color tokens.
///
/// Mirrors the design system's `colors_and_type.css`. Detectoo is a
/// monochrome-green system with a single terracotta accent family for
/// attention and AI/neural states — there are no secondary brand hues.
/// Restraint is the point: prefer these tokens over ad-hoc colors.
class DetectooColors {
  DetectooColors._();

  // ---------- Brand greens ----------
  /// Deepest green — body text on cream, dark surfaces, wordmark.
  static const Color green900 = Color(0xFF08372A);

  /// Alias used for dark surfaces in some mockups.
  static const Color green800 = Color(0xFF0B3B2E);

  /// Headings on cream.
  static const Color green700 = Color(0xFF14543F);

  /// Primary button, logo leaf fill.
  static const Color green600 = Color(0xFF1F7A54);

  /// Active accents, progress fills, the "oo" in the logo.
  static const Color green500 = Color(0xFF2FA36B);

  static const Color green400 = Color(0xFF5CC08C);

  /// Dark-BG highlights, soft green accents.
  static const Color green300 = Color(0xFF8BD6A9);

  static const Color green200 = Color(0xFFBCE6CC);

  /// Chip fills, quiet surfaces.
  static const Color green100 = Color(0xFFD9EED9);

  static const Color green050 = Color(0xFFE9F3E6);

  // ---------- Surfaces ----------
  /// THE signature app background — pale yellow-green cream.
  static const Color canvasCream = Color(0xFFEEF4DE);
  static const Color canvasCreamSoft = Color(0xFFF4F8E8);

  /// Slightly darker cream for nested sections / soft cards.
  static const Color canvasCreamDim = Color(0xFFE4EED0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceOff = Color(0xFFF7FAF0);

  /// Deep forest surfaces (vitals cards, image frames, dark banners).
  static const Color surfaceDark = Color(0xFF0B3B2E);
  static const Color surfaceDarkDeep = Color(0xFF052A1F);

  // ---------- Accent: terracotta/orange (single accent family) ----------
  /// Eyebrows, AI states, alerts, shutter button.
  static const Color terracotta = Color(0xFFD84A1E);
  static const Color terracottaStrong = Color(0xFFC23E15);
  static const Color terracottaSoft = Color(0xFFF3D8C9);
  static const Color terracottaBg = Color(0xFFFBEAE1);

  // ---------- Text ----------
  static const Color textStrong = green900;

  /// Slightly olive-warm body copy.
  static const Color textBody = Color(0xFF3D4A3A);

  /// Warm gray with an olive cast.
  static const Color textMuted = Color(0xFF6B6B5C);
  static const Color textFaint = Color(0xFF9A9A8A);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFFBCE6CC);

  // ---------- Borders & dividers ----------
  static const Color borderSoft = Color(0xFFE5E7DC);
  static const Color borderSofter = Color(0xFFEFF1E6);
  static const Color borderOnDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // ---------- Semantic ----------
  static const Color success = green500;
  static const Color warning = Color(0xFFD98B1E);
  static const Color danger = terracotta;
  static const Color info = green500;
}

/// Corner radii from the design system. The whole system is soft.
class DetectooRadii {
  DetectooRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;

  /// Pills, chips, mobile CTA buttons.
  static const double pill = 999;
}

/// Soft, low-opacity green-tinted shadows. No neon/glow effects.
class DetectooShadows {
  DetectooShadows._();

  /// Elevated white card shadow: `0 4px 16px rgba(11,59,46,0.06)`.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0B3B2E), // rgba(11,59,46,0.06)
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Slightly stronger card shadow: `0 8px 24px rgba(11,59,46,0.08)`.
  static const List<BoxShadow> cardMd = [
    BoxShadow(
      color: Color(0x140B3B2E), // rgba(11,59,46,0.08)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Floating bottom-nav capsule: `0 -2px 24px rgba(11,59,46,0.08)`.
  static const List<BoxShadow> nav = [
    BoxShadow(color: Color(0x140B3B2E), blurRadius: 24, offset: Offset(0, -2)),
  ];

  /// Raised terracotta FAB glow: `0 8px 24px rgba(216,74,30,0.28)`.
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x47D84A1E), // rgba(216,74,30,0.28)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
