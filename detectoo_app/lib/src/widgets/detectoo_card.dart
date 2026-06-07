import 'package:flutter/material.dart';

import '../theme/detectoo_colors.dart';

/// The three card archetypes in the Detectoo design system.
enum DetectooCardVariant {
  /// Elevated white card: white bg, soft green shadow, no border.
  /// The default — used for diagnosis summaries, reminders, list items.
  white,

  /// Soft cream card: a slightly darker cream, no shadow, no border.
  /// Acts as a quiet container that nests other cards (e.g. Active Recovery).
  cream,

  /// Dark forest card: deep green bg, white text, green-500 progress fills.
  /// Used for vitals/stat blocks (e.g. Current Vitals).
  dark,
}

/// A reusable card container matching the Detectoo design system.
///
/// Pick a [variant] to get the right surface treatment; all variants share
/// the soft 20px corner radius. Prefer this over ad-hoc [Container]
/// decorations so the three card looks stay consistent.
class DetectooCard extends StatelessWidget {
  /// The content of the card.
  final Widget child;

  /// Which card archetype to render. Defaults to [DetectooCardVariant.white].
  final DetectooCardVariant variant;

  /// Inner padding. Defaults to 20 on all sides.
  final EdgeInsetsGeometry padding;

  /// Corner radius. Defaults to 20.
  final double borderRadius;

  /// Optional tap handler. When set, the card becomes tappable with a ripple.
  final VoidCallback? onTap;

  /// Whether to clip the child to the rounded corners. Defaults to false;
  /// set true when the child has edge-to-edge imagery.
  final bool clip;

  const DetectooCard({
    super.key,
    required this.child,
    this.variant = DetectooCardVariant.white,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.onTap,
    this.clip = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    final (Color background, List<BoxShadow>? shadow) = switch (variant) {
      DetectooCardVariant.white => (
        DetectooColors.surfaceWhite,
        DetectooShadows.card,
      ),
      DetectooCardVariant.cream => (DetectooColors.canvasCreamDim, null),
      DetectooCardVariant.dark => (DetectooColors.surfaceDark, null),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        boxShadow: shadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          // Disable the splash/highlight when not interactive.
          splashColor: onTap == null ? Colors.transparent : null,
          highlightColor: onTap == null ? Colors.transparent : null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
