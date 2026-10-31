import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/quran_units.dart';

/// Horizontal juz selector (B2 quran map).
class JuzSlider extends StatelessWidget {
  const JuzSlider({super.key, required this.selected, required this.onChanged});

  final int selected; // 1..30
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: 30,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final juz = index + 1;
          final isSelected = juz == selected;
          return GestureDetector(
            onTap: () => onChanged(juz),
            child: Container(
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? tokens.brand : tokens.surfaceCard,
                borderRadius: BorderRadius.circular(tokens.radiusSmall),
                border: Border.all(
                  color: isSelected ? tokens.brand : tokens.borderStructural,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                '$juz',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : tokens.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One Quran page cell (square, R12): colored by rating, filled as a battery
/// for partial unit mastery (B2).
class PageGridCell extends StatelessWidget {
  const PageGridCell({
    super.key,
    required this.page,
    this.rating,
    this.progress = 0,
    this.onTap,
  });

  final int page;
  final int? rating; // 1..3 (latest unit rating)
  final double progress; // 0..1 units done on this page
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final rated = rating != null;
    final color = _colorForRating(rating, tokens);
    final tint = color.withValues(alpha: 0.18);
    final p = progress.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: rated ? tint : tokens.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: rated ? color : tokens.borderStructural,
            width: rated ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Battery-style fill from the bottom.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 4,
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: p,
                child: Container(
                  height: 4,
                  color: rated ? color : tokens.borderStructural,
                ),
              ),
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$page',
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: rated
                            ? _textColor(color, tokens)
                            : tokens.textMuted,
                      ),
                    ),
                    if (rated && rating! >= 3)
                      Icon(Icons.star, size: 10, color: color),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorForRating(int? rating, AppTokens tokens) {
    return switch (rating) {
      1 => tokens.reward,
      2 => tokens.infoLight,
      _ => tokens.brand,
    };
  }

  static Color _textColor(Color c, AppTokens tokens) =>
      c.computeLuminance() > 0.5 ? tokens.textPrimary : c;
}

/// Quran grid: always 7 columns; cells stay square and the grid height grows
/// only by the page count (3 rows for juz 1–29, 4 rows for juz 30).
class QuranGrid extends StatelessWidget {
  const QuranGrid({
    super.key,
    required this.juz,
    required this.pageStatus,
    this.columns = 7,
    this.onPageTap,
  });

  final int juz;
  final Map<int, ({int? rating, double progress})> pageStatus;
  final int columns;

  /// Called when a page cell is tapped (e.g. show its tasmi' details).
  final ValueChanged<int>? onPageTap;

  static const double spacing = 8;

  static int startPageOf(int juz) => juzStartPage(juz);

  static int pageCountOf(int juz) => juzPageCount(juz);

  static int rowsFor(int juz, {int columns = 7}) =>
      (pageCountOf(juz) / columns).ceil();

  /// Height that keeps every cell square for a given available width.
  static double heightFor(int juz, double width, {int columns = 7}) {
    final side = (width - spacing * (columns - 1)) / columns;
    final rows = rowsFor(juz, columns: columns);
    return side * rows + spacing * (rows - 1);
  }

  @override
  Widget build(BuildContext context) {
    final start = startPageOf(juz);
    final count = pageCountOf(juz);
    final pages = [for (var i = 0; i < count; i++) start + i];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final side = (width - spacing * (columns - 1)) / columns;
        if (side <= 0) return const SizedBox.shrink();
        final rows = (pages.length / columns).ceil();
        return SizedBox(
          height: side * rows + spacing * (rows - 1),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: side,
            ),
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              final status = pageStatus[page];
              return PageGridCell(
                page: page,
                rating: status?.rating,
                progress: status?.progress ?? 0,
                onTap: onPageTap == null ? null : () => onPageTap!(page),
              );
            },
          ),
        );
      },
    );
  }
}
