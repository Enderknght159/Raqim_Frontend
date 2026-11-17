import 'package:flutter/material.dart';

import '../utils/numeral_utils.dart';
import 'app_card.dart';
import 'icon_tile.dart';
import '../theme/app_theme.dart';

/// A compact dashboard stat card: the icon and its label share the top row,
/// and the numeric value sits large and centred underneath.
///
/// The value is wrapped in a [FittedBox] so a long number can never collide
/// with (or push out) the header row.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brand;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  IconTile(icon: icon!, color: accent, size: 30, iconSize: 16),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Tooltip(
                    message: label,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatNumber(value),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: accent,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
