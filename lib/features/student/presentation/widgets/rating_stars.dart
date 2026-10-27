import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Rating display (1–3 for memorization) as colored stars.
/// Used in the tasmi' logs (Quran + course detail).
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.iconSize = 14});

  final int rating; // 1..3
  final double iconSize;

  static Color colorFor(int rating, AppTokens tokens) => switch (rating) {
    1 => tokens.reward,
    2 => tokens.infoLight,
    _ => tokens.brand,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$rating',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colorFor(rating, tokens),
          ),
        ),
        const SizedBox(width: 2),
        Icon(Icons.star, size: iconSize, color: colorFor(rating, tokens)),
      ],
    );
  }
}
