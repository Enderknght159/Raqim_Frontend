import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Thin rounded progress bar (4–8px); optional split into two segments for
/// partial mastery (battery style).
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
    this.trackColor,
    this.label,
  });

  /// 0–1.
  final double value;
  final Color? color;
  final double height;
  final Color? trackColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brand;
    final clamped = value.clamp(0.0, 1.0);
    final track = trackColor ?? tokens.surfaceSubtle;
    final bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(height),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
    return label == null
        ? bar
        : Row(
            children: [
              Expanded(child: bar),
              const SizedBox(width: 8),
              Text(
                label!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ],
          );
  }
}

/// Battery-style two-segment bar (partial unit mastery). Each segment shows
/// its fraction via [filledA]/[filledB] in [0..1].
class SplitProgressBar extends StatelessWidget {
  const SplitProgressBar({
    super.key,
    required this.filledA,
    required this.filledB,
    this.colorA,
    this.colorB,
    this.height = 8,
  });

  final double filledA;
  final double filledB;
  final Color? colorA;
  final Color? colorB;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accentA = colorA ?? tokens.brand;
    final accentB = colorB ?? tokens.info;
    final track = tokens.surfaceSubtle;

    Widget segment(double filled, Color accent) {
      return Expanded(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(height),
          ),
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: filled.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        segment(filledA, accentA),
        const SizedBox(width: 4),
        segment(filledB, accentB),
      ],
    );
  }
}
