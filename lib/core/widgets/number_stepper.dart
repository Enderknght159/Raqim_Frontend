import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Compact, tactile number stepper (− value +): the recommended replacement
/// for sliders when picking small bounded integers (session points, course
/// criteria…). Each button keeps a ≥44px touch target.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.label,
    this.suffix,
    this.color,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  /// Optional caption above the control.
  final String? label;
  final String? suffix;

  /// Accent color for the value text (defaults to the brand text token).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final valueColor = color ?? tokens.textPrimary;
    final canDec = value > min;
    final canInc = value < max;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              onPressed: canDec ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 46,
              child: Text(
                suffix == null ? '$value' : '$value $suffix',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                    ),
              ),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              onPressed: canInc ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final enabled = onPressed != null;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: enabled ? tokens.brandText : tokens.textMuted,
      style: IconButton.styleFrom(
        backgroundColor:
            enabled ? tokens.brandTint : tokens.surfaceSubtle,
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: enabled ? tokens.brandBorder : tokens.borderStructural,
          ),
        ),
      ),
    );
  }
}
