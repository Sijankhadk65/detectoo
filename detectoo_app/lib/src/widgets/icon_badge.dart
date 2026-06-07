import 'package:flutter/material.dart';

import '../theme/detectoo_colors.dart';

/// A Material-Symbols-style icon sitting inside a soft rounded tile.
///
/// Used as a visual marker in list rows, option tiles, and the condition
/// tiles (Light / Water / Temp / Soil). Defaults to a quiet green-100 tile
/// with a green-600 glyph; pass [iconColor] / [backgroundColor] for
/// semantic tints (e.g. terracotta for alerts).
class IconBadge extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon. Defaults to 20.
  final double iconSize;

  /// The padding around the icon. Defaults to 10.
  final double padding;

  /// The border radius of the tile. Defaults to 12.
  final double borderRadius;

  /// Optional custom tile color. Derives a soft tint from [iconColor]
  /// when null.
  final Color? backgroundColor;

  /// Optional custom glyph color. Defaults to brand green-600.
  final Color? iconColor;

  const IconBadge({
    super.key,
    required this.icon,
    this.iconSize = 20,
    this.padding = 10,
    this.borderRadius = 12,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? DetectooColors.green600;
    final effectiveBackground =
        backgroundColor ??
        (iconColor == null
            ? DetectooColors.green100
            : effectiveIconColor.withValues(alpha: 0.12));

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, size: iconSize, color: effectiveIconColor),
    );
  }
}
