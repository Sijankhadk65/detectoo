import 'package:flutter/material.dart';

/// A reusable card container with consistent border and styling.
///
/// Provides the standard Detectoo card appearance: surface background,
/// rounded corners (14px), and a subtle outline border. Used as the
/// base container for list items, info sections, and grouped content.
class DetectooCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Optional custom border color. Defaults to the theme's outlineVariant.
  final Color? borderColor;

  /// Optional bottom margin. Defaults to 10.
  final double bottomMargin;

  /// Optional padding. Defaults to EdgeInsets.all(16).
  final EdgeInsetsGeometry padding;

  /// Optional tap handler. When provided, the card becomes tappable.
  final VoidCallback? onTap;

  const DetectooCard({
    super.key,
    required this.child,
    this.borderColor,
    this.bottomMargin = 10,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBorderColor =
        borderColor ?? colorScheme.outlineVariant.withValues(alpha: 0.5);

    final card = Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
