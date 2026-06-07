import 'package:flutter/material.dart';

import '../theme/detectoo_colors.dart';

/// A deep-forest hero banner.
///
/// The design system allows exactly one gradient — the forest-green dark
/// surface (`#0B3B2E → #052A1F`). This banner uses it for greeting headers
/// and feature sections, with optional soft green decorative circles. All
/// content inside should use light-on-dark colors.
class GradientBanner extends StatelessWidget {
  /// The content of the banner.
  final Widget child;

  /// Optional override of the two gradient stops. Defaults to forest green.
  final List<Color>? colors;

  /// Corner radius. Defaults to 24.
  final double borderRadius;

  /// Inner padding. Defaults to EdgeInsets.all(24).
  final EdgeInsetsGeometry padding;

  /// Whether to show the soft decorative circles. Defaults to true.
  final bool showDecoration;

  const GradientBanner({
    super.key,
    required this.child,
    this.colors,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(24),
    this.showDecoration = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        colors ??
        const [DetectooColors.surfaceDark, DetectooColors.surfaceDarkDeep];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: DetectooShadows.cardMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showDecoration) ...[
              Positioned(
                top: -30,
                right: -20,
                child: _circle(120, DetectooColors.green300, 0.10),
              ),
              Positioned(
                bottom: -40,
                left: -30,
                child: _circle(150, DetectooColors.green500, 0.08),
              ),
            ],
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }
}
