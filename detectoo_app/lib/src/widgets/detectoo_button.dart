import 'package:flutter/material.dart';

import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';

/// The visual variant of a [DetectooButton].
enum DetectooButtonVariant {
  /// Solid green-600 fill, white label. The default primary action.
  primary,

  /// Solid terracotta fill, white label. For AI/attention actions.
  accent,

  /// Transparent fill with a green-300 outline and green-700 label.
  ghost,
}

/// A full-width pill-shaped action button with Detectoo styling.
///
/// Matches the design system's `.ds-btn` family: pill radius, bold display
/// label, solid fills for [DetectooButtonVariant.primary] /
/// [DetectooButtonVariant.accent], and an outlined
/// [DetectooButtonVariant.ghost]. Presses scale the button to 0.97 with no
/// hue change, per the brand's quiet interaction style.
class DetectooButton extends StatefulWidget {
  /// The button label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the button is pressed. When null, the button is disabled.
  final VoidCallback? onPressed;

  /// The button variant. Defaults to [DetectooButtonVariant.primary].
  final DetectooButtonVariant variant;

  /// The button height. Defaults to 52.
  final double height;

  /// Optional override for the fill (solid variants) or outline/label
  /// (ghost variant). When null, the variant's brand color is used.
  final Color? color;

  /// Whether the button stretches to fill its parent width. Defaults to true.
  final bool fullWidth;

  const DetectooButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = DetectooButtonVariant.primary,
    this.height = 52,
    this.color,
    this.fullWidth = true,
  });

  /// Convenience constructor for the outlined/ghost variant, kept for
  /// call sites that used the previous `outlined: true` API.
  const DetectooButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.color,
    this.fullWidth = true,
  }) : variant = DetectooButtonVariant.ghost;

  @override
  State<DetectooButton> createState() => _DetectooButtonState();
}

class _DetectooButtonState extends State<DetectooButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isGhost = widget.variant == DetectooButtonVariant.ghost;
    final enabled = widget.onPressed != null;

    final Color fill = switch (widget.variant) {
      DetectooButtonVariant.primary => widget.color ?? DetectooColors.green600,
      DetectooButtonVariant.accent => widget.color ?? DetectooColors.terracotta,
      DetectooButtonVariant.ghost => Colors.transparent,
    };
    final Color foreground = isGhost
        ? (widget.color ?? DetectooColors.green700)
        : Colors.white;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: foreground, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: DetectooText.bodyStrong.copyWith(color: foreground),
        ),
      ],
    );

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: fill,
          borderRadius: BorderRadius.circular(DetectooRadii.pill),
          child: InkWell(
            onTap: widget.onPressed,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: BorderRadius.circular(DetectooRadii.pill),
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: widget.height,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DetectooRadii.pill),
                border: isGhost
                    ? Border.all(color: widget.color ?? DetectooColors.green300)
                    : null,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
