import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detectoo_colors.dart';
import 'detectoo_text_styles.dart';

/// Builds the app-wide [ThemeData] for Detectoo.
///
/// Anchors the signature cream canvas, the monochrome-green + terracotta
/// palette, the Plus Jakarta Sans / Nunito type pairing, pill-shaped
/// buttons, and the soft green-tinted surfaces described in the design
/// system. Screens and widgets should read from this theme (and the
/// [DetectooColors] / [DetectooText] tokens) rather than hardcoding values.
ThemeData detectooTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: DetectooColors.green600,
    onPrimary: Colors.white,
    primaryContainer: DetectooColors.green100,
    onPrimaryContainer: DetectooColors.green700,
    secondary: DetectooColors.terracotta,
    onSecondary: Colors.white,
    secondaryContainer: DetectooColors.terracottaBg,
    onSecondaryContainer: DetectooColors.terracottaStrong,
    tertiary: DetectooColors.green500,
    onTertiary: Colors.white,
    error: DetectooColors.danger,
    onError: Colors.white,
    surface: DetectooColors.surfaceWhite,
    onSurface: DetectooColors.textStrong,
    surfaceContainerLowest: DetectooColors.surfaceWhite,
    surfaceContainerLow: DetectooColors.canvasCreamSoft,
    surfaceContainer: DetectooColors.canvasCream,
    surfaceContainerHigh: DetectooColors.canvasCreamDim,
    onSurfaceVariant: DetectooColors.textMuted,
    outline: DetectooColors.borderSoft,
    outlineVariant: DetectooColors.borderSofter,
    shadow: DetectooColors.surfaceDark,
    inverseSurface: DetectooColors.surfaceDark,
    onInverseSurface: Colors.white,
  );

  final textTheme = TextTheme(
    displayLarge: DetectooText.display,
    displayMedium: DetectooText.h1,
    headlineMedium: DetectooText.h1,
    headlineSmall: DetectooText.h2,
    titleLarge: DetectooText.h2,
    titleMedium: DetectooText.h3,
    titleSmall: DetectooText.bodyStrong,
    bodyLarge: DetectooText.body,
    bodyMedium: DetectooText.body,
    bodySmall: DetectooText.small,
    labelLarge: DetectooText.bodyStrong,
    labelMedium: DetectooText.small,
    labelSmall: DetectooText.eyebrow,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: DetectooColors.canvasCream,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    fontFamily: GoogleFonts.nunito().fontFamily,
    iconTheme: const IconThemeData(color: DetectooColors.green700),
    dividerTheme: const DividerThemeData(
      color: DetectooColors.borderSoft,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: DetectooColors.canvasCream,
      foregroundColor: DetectooColors.green700,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: DetectooText.h3.copyWith(color: DetectooColors.green700),
      iconTheme: const IconThemeData(color: DetectooColors.green700),
    ),
    cardTheme: CardThemeData(
      color: DetectooColors.surfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DetectooRadii.xl),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DetectooColors.green600,
        foregroundColor: Colors.white,
        textStyle: DetectooText.bodyStrong.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DetectooColors.green600,
        foregroundColor: Colors.white,
        textStyle: DetectooText.bodyStrong.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DetectooColors.green700,
        textStyle: DetectooText.bodyStrong.copyWith(
          color: DetectooColors.green700,
        ),
        side: const BorderSide(color: DetectooColors.green300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DetectooColors.terracotta,
        textStyle: DetectooText.bodyStrong,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DetectooColors.surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: DetectooText.body.copyWith(color: DetectooColors.textFaint),
      labelStyle: DetectooText.small,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DetectooRadii.md),
        borderSide: const BorderSide(color: DetectooColors.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DetectooRadii.md),
        borderSide: const BorderSide(color: DetectooColors.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DetectooRadii.md),
        borderSide: const BorderSide(
          color: DetectooColors.green500,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DetectooRadii.md),
        borderSide: const BorderSide(color: DetectooColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DetectooRadii.md),
        borderSide: const BorderSide(color: DetectooColors.danger, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: DetectooColors.green100,
      labelStyle: DetectooText.small.copyWith(
        color: DetectooColors.green700,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DetectooColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: DetectooColors.surfaceDark,
      contentTextStyle: DetectooText.body.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DetectooRadii.md),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: DetectooColors.green500,
      linearTrackColor: DetectooColors.green100,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: DetectooColors.surfaceWhite,
      indicatorColor: DetectooColors.green600,
      labelTextStyle: WidgetStateProperty.all(
        DetectooText.small.copyWith(fontSize: 11),
      ),
    ),
  );
}
