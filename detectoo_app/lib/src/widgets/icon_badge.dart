import 'package:flutter/material.dart';

/// A small icon displayed inside a rounded, lightly colored container.
///
/// Used as a visual marker in list items, cards, and option tiles
/// throughout the app. The background color automatically derives
/// from the icon color, creating a cohesive tinted effect that works
/// with both the primary green and accent amber palettes.
class IconBadge extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon. Defaults to 20.
  final double iconSize;

  /// The padding around the icon. Defaults to 8.
  final double padding;

  /// The border radius of the container. Defaults to 10.
  final double borderRadius;

  /// Optional custom background color. When null, derives a tinted
  /// background from the [iconColor] or theme primary.
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
    final effectiveIconColor = iconColor ?? colorScheme.primary;
    final effectiveBackground =
        backgroundColor ?? effectiveIconColor.withValues(alpha: 0.12);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: effectiveIconColor,
      ),
    );
  }
}
