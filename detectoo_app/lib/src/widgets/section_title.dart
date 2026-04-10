import 'package:flutter/material.dart';

/// A reusable section title row with an icon and heading text.
///
/// Used across screens to introduce content sections with a
/// consistent Georgia font style and primary-colored icon.
class SectionTitle extends StatelessWidget {
  /// The title text to display.
  final String title;

  /// The icon displayed before the title.
  final IconData icon;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
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
