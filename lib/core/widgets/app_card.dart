import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Flat, rounded surface used for cards across the app (light mode).
///
/// Style rule (`ui-ux-foundations.md` §3): **no shadows/gradients/glow** —
/// depth comes from hairline borders only. Unified radius 12.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.radius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Card background color. Defaults to `tokens.surfaceCard`.
  final Color? color;

  /// Tinted outline color; defaults to `tokens.borderStructural`.
  final Color? borderColor;

  final double borderWidth;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final radiusValue = radius ?? tokens.radiusMedium;

    final decoration = BoxDecoration(
      color: color ?? tokens.surfaceCard,
      borderRadius: BorderRadius.circular(radiusValue),
      border: Border.all(
        color: borderColor ?? tokens.borderStructural,
        width: borderWidth,
      ),
    );

    if (onTap == null) {
      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding, child: child),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusValue),
        child: DecoratedBox(
          decoration: decoration,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
