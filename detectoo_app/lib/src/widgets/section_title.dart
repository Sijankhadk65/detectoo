import 'package:flutter/material.dart';

/// A reusable section title row with an icon in a tinted pill
/// and heading text.
///
/// Used across screens to introduce content sections with a
/// consistent Georgia font style and a colored icon badge for
/// visual weight in the dual-palette design.
class SectionTitle extends StatelessWidget {
  /// The title text to display.
  final String title;

  /// The icon displayed before the title.
  final IconData icon;

  /// Optional custom color for the icon and its background pill.
  final Color? iconColor;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = iconColor ?? colorScheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: effectiveColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
