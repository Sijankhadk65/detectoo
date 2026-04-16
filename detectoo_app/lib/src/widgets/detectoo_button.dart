import 'package:flutter/material.dart';

/// A full-width action button with consistent Detectoo styling.
///
/// Supports both filled (gradient) and outlined variants.
/// Filled buttons use a gradient background with a colored shadow
/// for a modern, eye-catching look. Used for primary actions like
/// "Log In", "Add to My Plants", "Start Recovery Plan", etc.
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
  /// or base color for filled button gradient.
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

    // Filled variant: gradient container wrapping an invisible button.
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            effectiveColor,
            HSLColor.fromColor(effectiveColor)
                .withHue(
                    (HSLColor.fromColor(effectiveColor).hue + 12) % 360)
                .withSaturation(
                    (HSLColor.fromColor(effectiveColor).saturation * 0.9)
                        .clamp(0.0, 1.0))
                .toColor(),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
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
}
