import 'package:flutter/material.dart';

/// A full-width action button with consistent Detectoo styling.
///
/// Supports both filled (elevated) and outlined variants.
/// Used for primary actions like "Log In", "Add to My Plants",
/// "Start Recovery Plan", etc.
class DetectooButton extends StatelessWidget {
  /// The button label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// Whether to use the outlined style. Defaults to false (filled).
  final bool outlined;

  /// The button height. Defaults to 50.
  final double height;

  /// Optional custom foreground color for outlined buttons,
  /// or background color for filled buttons.
  final Color? color;

  const DetectooButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.height = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
                style: _outlinedStyle(effectiveColor),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: _outlinedStyle(effectiveColor),
                child: Text(label),
              ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: _filledStyle(effectiveColor, colorScheme),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: _filledStyle(effectiveColor, colorScheme),
              child: Text(label),
            ),
    );
  }

  ButtonStyle _outlinedStyle(Color foreground) {
    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      side: BorderSide(color: foreground, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  ButtonStyle _filledStyle(Color background, ColorScheme colorScheme) {
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: colorScheme.onPrimary,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
