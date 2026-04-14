import 'package:flutter/material.dart';

/// A reusable card container with consistent border and styling.
///
/// Provides the standard Detectoo card appearance with rounded corners,
/// optional elevation, optional gradient backgrounds, and an optional
/// accent side strip for visual variety in a dual-palette design.
class DetectooCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Optional custom border color. When set, draws a border.
  final Color? borderColor;

  /// Optional bottom margin. Defaults to 10.
  final double bottomMargin;

  /// Optional padding. Defaults to EdgeInsets.all(16).
  final EdgeInsetsGeometry padding;

  /// Optional tap handler. When provided, the card becomes tappable.
  final VoidCallback? onTap;

  /// Elevation level controlling shadow intensity. Defaults to 1.
  final double elevation;

  /// Optional gradient background. When set, overrides the solid
  /// background color.
  final Gradient? gradient;

  /// Optional accent color for a thin left-side strip.
  /// Adds a 4px wide colored strip on the left edge of the card.
  final Color? accentColor;

  const DetectooCard({
    super.key,
    required this.child,
    this.borderColor,
    this.bottomMargin = 10,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.elevation = 1,
    this.gradient,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final cardContent = Container(
      margin: EdgeInsets.only(bottom: bottomMargin, left: 10, right: 10),
      decoration: BoxDecoration(
        color: gradient == null ? colorScheme.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.06 * elevation),
                  blurRadius: 5 * elevation,
                  offset: Offset(0, 2 * elevation),
                ),
              ]
            : null,
      ),
      child: accentColor != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(width: 4, color: accentColor),
                  Expanded(
                    child: Padding(padding: padding, child: child),
                  ),
                ],
              ),
            )
          : Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}
