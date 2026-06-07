import 'package:flutter/material.dart';

import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';

/// A small UPPERCASE, letter-tracked eyebrow label.
///
/// The universal lead-in for the "eyebrow → H1 → body" header structure
/// used across every Detectoo screen (e.g. "BOTANICAL DASHBOARD",
/// "AI DIAGNOSIS RESULT", "DIAGNOSIS CONFIRMED"). Defaults to the
/// terracotta accent; pass [green] for the quieter green-500 variant.
class EyebrowLabel extends StatelessWidget {
  /// The label text. Rendered uppercase regardless of input casing.
  final String text;

  /// Use the green-500 accent instead of terracotta.
  final bool green;

  const EyebrowLabel(this.text, {super.key, this.green = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: DetectooText.eyebrow.copyWith(
        color: green ? DetectooColors.green500 : DetectooColors.terracotta,
      ),
    );
  }
}
