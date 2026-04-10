import 'package:flutter/material.dart';

/// A small icon displayed inside a rounded, lightly colored container.
///
/// Used as a visual marker in list items, cards, and option tiles
/// throughout the app. Defaults to the theme's primaryContainer
/// background and primary icon color.
class IconBadge extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon. Defaults to 20.
  final double iconSize;

  /// The padding around the icon. Defaults to 8.
  final double padding;

  /// The border radius of the container. Defaults to 10.
  final double borderRadius;

  /// Optional custom background color. Defaults to primaryContainer
  /// with 0.3 alpha.
  final Color? backgroundColor;

  /// Optional custom icon color. Defaults to the theme's primary color.
  final Color? iconColor;

  const IconBadge({
    super.key,
    required this.icon,
    this.iconSize = 20,
    this.padding = 8,
    this.borderRadius = 10,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ??
            colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? colorScheme.primary,
      ),
    );
  }
}
