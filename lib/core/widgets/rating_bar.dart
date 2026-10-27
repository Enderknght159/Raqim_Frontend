import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One level of a [RatingBar].
class RatingLevel {
  const RatingLevel({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color? color;
}

/// Default memorization rating levels (BR-512): جيد / جيد جدًا / ممتاز.
const List<RatingLevel> kMemorizationRatingLevels = [
  RatingLevel(value: 1, label: 'جيد', icon: Icons.sentiment_satisfied_alt),
  RatingLevel(
    value: 2,
    label: 'جيد جدًا',
    icon: Icons.sentiment_very_satisfied,
  ),
  RatingLevel(value: 3, label: 'ممتاز', icon: Icons.emoji_events_outlined),
];

/// Interactive segmented rating bar (replaces multi-select rating inputs).
class RatingBar extends StatelessWidget {
  const RatingBar({
    super.key,
    required this.levels,
    required this.value,
    required this.onChanged,
  });

  final List<RatingLevel> levels;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < levels.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(child: _segment(context, tokens, levels[i])),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          levels
              .firstWhere((l) => l.value == value, orElse: () => levels.first)
              .label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: tokens.info,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _segment(BuildContext context, AppTokens tokens, RatingLevel level) {
    final selected = level.value == value;
    final accent = level.color ?? tokens.brand;
    return InkWell(
      onTap: () => onChanged(level.value),
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.16)
              : tokens.surfaceSubtle,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(
            color: selected ? accent : tokens.borderStructural,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              level.icon,
              size: 20,
              color: selected ? accent : tokens.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              '${level.value}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? accent : tokens.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
