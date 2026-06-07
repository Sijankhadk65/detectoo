import 'package:flutter/material.dart';

import '../theme/detectoo_text_styles.dart';
import 'icon_badge.dart';

/// A section heading row: a tinted [IconBadge] followed by an H3 title.
///
/// Used to introduce content sections with consistent Plus Jakarta Sans
/// styling and a colored icon tile for visual weight.
class SectionTitle extends StatelessWidget {
  /// The title text.
  final String title;

  /// The icon displayed before the title.
  final IconData icon;

  /// Optional custom color for the icon and its tile.
  final Color? iconColor;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconBadge(icon: icon, iconColor: iconColor, iconSize: 18, padding: 8),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: DetectooText.h3)),
      ],
    );
  }
}
