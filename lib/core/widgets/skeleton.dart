import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Static skeleton placeholder (loading). Matches `ui-ux-foundations.md`
/// flat style — no gradients/shimmer.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height = 16, this.width, this.radius});

  final double height;
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle,
        borderRadius: BorderRadius.circular(radius ?? 8),
      ),
    );
  }
}

/// Column of skeleton rows, e.g. `[SkeletonBlock(rows: 4)]` for card lists.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.rows = 4, this.height = 16});

  final int rows;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Skeleton(height: height),
          ),
      ],
    );
  }
}
