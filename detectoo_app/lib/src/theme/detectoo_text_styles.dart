import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detectoo_colors.dart';

/// Detectoo typography tokens.
///
/// Headlines use Plus Jakarta Sans at extrabold (800) with tight tracking
/// and leading; body copy uses Nunito at lighter, warmer weights. This
/// mirrors the design system's type scale (`colors_and_type.css`).
///
/// Prefer these styles over inline [TextStyle]s so the brand voice stays
/// consistent. Use [copyWith] for per-use color/size tweaks.
class DetectooText {
  DetectooText._();

  /// Hero / splash title — 48px / 800 / very tight.
  static TextStyle get display => GoogleFonts.plusJakartaSans(
    fontSize: 44,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: DetectooColors.textStrong,
  );

  /// Screen titles — 34px / 800.
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: DetectooColors.textStrong,
  );

  /// Section headers — 24px / 700.
  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: DetectooColors.textStrong,
  );

  /// Card titles — 18px / 700.
  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: DetectooColors.textStrong,
  );

  /// Body copy — 15px / 400 Nunito.
  static TextStyle get body => GoogleFonts.nunito(
    fontSize: 15,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: DetectooColors.textBody,
  );

  /// Emphasised body — 15px / 700 Nunito.
  static TextStyle get bodyStrong => GoogleFonts.nunito(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: DetectooColors.textStrong,
  );

  /// Captions / small labels — 13px / 500.
  static TextStyle get small => GoogleFonts.nunito(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: DetectooColors.textMuted,
  );

  /// Eyebrow labels — 11px / 700 / UPPERCASE / tracked terracotta.
  static TextStyle get eyebrow => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    height: 1,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.3,
    color: DetectooColors.terracotta,
  );
}
