import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded square icon container with a tinted fill + tinted border
/// (stitch draft: `w-8 h-8 rounded-lg bg-primary/15 text-primary border border-primary/20`).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.color,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius = 10,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final double iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brand;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: iconSize, color: accent),
    );
  }
}
