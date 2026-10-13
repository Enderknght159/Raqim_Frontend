import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'icon_tile.dart';

/// Section header: icon in an [IconTile] + title (+ optional badge/action).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.color,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      children: [
        if (icon != null) ...[
          IconTile(icon: icon!, color: color, size: 36, iconSize: 18),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}