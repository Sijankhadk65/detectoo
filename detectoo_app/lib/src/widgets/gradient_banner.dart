import 'package:flutter/material.dart';

/// A hero banner with a gradient background and decorative elements.
///
/// Used for greeting cards, screen headers, and feature sections
/// that need a visually rich, eye-catching appearance. Supports
/// warm-tinted decorative accents for visual variety.
class GradientBanner extends StatelessWidget {
  /// The main content of the banner.
  final Widget child;

  /// Gradient colors. Defaults to a green-teal gradient.
  final List<Color>? colors;

  /// Optional gradient begin alignment. Defaults to topLeft.
  final AlignmentGeometry begin;

  /// Optional gradient end alignment. Defaults to bottomRight.
  final AlignmentGeometry end;

  /// Border radius. Defaults to 20.
  final double borderRadius;

  /// Padding inside the banner. Defaults to EdgeInsets.all(24).
  final EdgeInsetsGeometry padding;

  /// Whether to show decorative circle overlays. Defaults to true.
  final bool showDecoration;

  /// Elevation level. Defaults to 2.
  final double elevation;

  /// Optional accent color for decorative circles. Defaults to white.
  final Color? accentColor;

  const GradientBanner({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(24),
    this.showDecoration = true,
    this.elevation = 2,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColors = colors ??
        [
          colorScheme.primary,
          const Color(0xFF00897B),
        ];
    final decorColor = accentColor ?? Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: effectiveColors,
          begin: begin,
          end: end,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: effectiveColors.first.withValues(alpha: 0.3),
            blurRadius: 12 * elevation,
            offset: Offset(0, 4 * elevation),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showDecoration) ...[
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: decorColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: decorColor.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Warm accent circle for dual-palette interest
              Positioned(
                top: 10,
                right: 50,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                  ),
                ),
              ),
            ],
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
