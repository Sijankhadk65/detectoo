import 'package:flutter/material.dart';

import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';

/// A pill-shaped status badge.
///
/// Two looks from the design system's `.ds-chip`:
/// - default: a quiet green-100 fill with green-700 label, for health
///   statuses and categorical tags.
/// - [accent]: a solid terracotta fill with white, UPPERCASE, tracked text,
///   for attention badges like "2 PLANS" or "AI DIAGNOSIS RESULT".
///
/// Pass a [color] to tint the default (quiet) variant for semantic states.
class StatusChip extends StatelessWidget {
  /// The label text.
  final String label;

  /// Use the solid terracotta accent treatment (uppercase, tracked).
  final bool accent;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional tint for the quiet variant. Defaults to brand green.
  final Color? color;

  const StatusChip({
    super.key,
    required this.label,
    this.accent = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (accent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color ?? DetectooColors.terracotta,
          borderRadius: BorderRadius.circular(DetectooRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              label.toUpperCase(),
              style: DetectooText.eyebrow.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }

    final tint = color ?? DetectooColors.green600;
    final isGreen = color == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isGreen ? DetectooColors.green100 : tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DetectooRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isGreen ? DetectooColors.green700 : tint,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: DetectooText.small.copyWith(
              color: isGreen ? DetectooColors.green700 : tint,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
