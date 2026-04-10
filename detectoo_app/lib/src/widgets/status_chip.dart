import 'package:flutter/material.dart';

/// A pill-shaped badge displaying a status label.
///
/// Used to show health statuses, recovery progress labels,
/// severity indicators, and other short categorical labels
/// with a colored background and text.
class StatusChip extends StatelessWidget {
  /// The label text to display.
  final String label;

  /// The accent color used for background and text.
  final Color color;

  /// Whether to show a border around the chip. Defaults to false.
  final bool showBorder;

  /// Optional background alpha. Defaults to 0.1.
  final double backgroundAlpha;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.showBorder = false,
    this.backgroundAlpha = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(20),
        border: showBorder
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
