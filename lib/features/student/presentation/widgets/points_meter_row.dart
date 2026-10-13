import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A label/value row used in the points breakdown sheet (per source).
class PointsMeterRow extends StatelessWidget {
  const PointsMeterRow({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brandText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: value < 0 ? tokens.danger : accent,
            ),
          ),
        ],
      ),
    );
  }
}