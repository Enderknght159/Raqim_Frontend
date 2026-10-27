import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/student_models.dart';
import '../../domain/quran_units.dart';
import 'quran_grid.dart';
import 'rating_stars.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Latest rating per (page,partIndex); per page rating = max rating,
/// progress = covered parts / total parts.
Map<int, ({int? rating, double progress})> computeQuranPageStatus(
  List<Memorization> memorizations,
) {
  final latest = <String, Memorization>{};
  for (final m in memorizations) {
    final key = '${m.page}:${m.partIndex}';
    final existing = latest[key];
    if (existing == null || m.date.isAfter(existing.date)) latest[key] = m;
  }
  final byPage = <int, List<Memorization>>{};
  for (final m in latest.values) {
    byPage.putIfAbsent(m.page, () => []).add(m);
  }
  return {
    for (final entry in byPage.entries)
      entry.key: (
        rating: entry.value
            .map((m) => m.rating)
            .reduce((a, b) => a > b ? a : b),
        progress:
            (entry.value.length /
                    (entry.value.first.parts <= 0
                        ? 1
                        : entry.value.first.parts))
                .clamp(0.0, 1.0),
      ),
  };
}

/// The student "خريطة الحفظ" map (B2): a juz quick-slider + a horizontally
/// paged 30-juz view (looping from juz 30 back to juz 1). Reused by the
/// student Quran tab and the admin student profile (E7).
class QuranMap extends StatefulWidget {
  const QuranMap({
    super.key,
    required this.memorizations,
    required this.testedJuz,
    this.height = 250,
  });

  final List<Memorization> memorizations;
  final Set<int> testedJuz;

  /// Height of the paged grid area.
  final double height;

  @override
  State<QuranMap> createState() => _QuranMapState();
}

class _QuranMapState extends State<QuranMap> {
  // A multiple of 30 so `index % 30` always maps to the correct juz — this
  // gives a looping (infinite) page view from juz 30 back to juz 1.
  static const int _basePage = 900;
  static const int _loopCount = 50; // 1500 pages total (50 full cycles).

  late final PageController _controller;
  late int _currentJuz;
  late Map<int, ({int? rating, double progress})> _pageStatus;

  @override
  void initState() {
    super.initState();
    _pageStatus = computeQuranPageStatus(widget.memorizations);
    _currentJuz = _computeInitialJuz();
    _controller = PageController(initialPage: _pageFor(_currentJuz));
  }

  @override
  void didUpdateWidget(QuranMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.memorizations != widget.memorizations) {
      _pageStatus = computeQuranPageStatus(widget.memorizations);
    }
  }

  int _computeInitialJuz() {
    if (widget.memorizations.isEmpty) return 30;
    final latestPage = widget.memorizations
        .map((m) => m.page)
        .reduce((a, b) => a > b ? a : b);
    return juzOfPage(latestPage);
  }

  int _pageFor(int juz) => _basePage + (juz - 1);

  void _jumpToJuz(int juz) {
    _controller.animateToPage(
      _pageFor(juz),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Tap on a page cell → its tasmi' details: each unit with the reciter,
  /// date and rating.
  void _showPageTasmi(BuildContext context, int page) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final pageMems = widget.memorizations.where((m) => m.page == page).toList();
    // Latest record per unit (page may hold 1–3 units).
    final latest = <int, Memorization>{};
    for (final m in pageMems) {
      final existing = latest[m.partIndex];
      if (existing == null || m.date.isAfter(existing.date)) {
        latest[m.partIndex] = m;
      }
    }
    final units = latest.values.toList()
      ..sort((a, b) => a.partIndex.compareTo(b.partIndex));
    final surahs = quranPageSurahs[page] ?? const <String>[];

    showAppSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories_outlined, color: tokens.brand),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'صفحة $page',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 6),
                  StatusBadge(
                    label: '${units.length} وحدة مسجّلة',
                    color: units.isEmpty ? tokens.textMuted : tokens.brand,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                surahs.isEmpty
                    ? (units.isEmpty
                          ? '—'
                          : quranSurahOf(page, units.first.partIndex))
                    : surahs.join(' · '),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
              const SizedBox(height: 8),
              if (units.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'لا تسميعات مسجّلة لهذه الصفحة',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final m in units)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.menu_book,
                      color: RatingStars.colorFor(m.rating, tokens),
                    ),
                    title: Text(
                      'الوحدة ${m.partIndex} — ${quranSurahOf(page, m.partIndex)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'المسمِّع: ${m.reciterName} · ${formatDate(m.date)}',
                    ),
                    trailing: RatingStars(rating: m.rating),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick slider: jump instantly between the 30 juz.
        JuzSlider(selected: _currentJuz, onChanged: _jumpToJuz),
        const SizedBox(height: 10),
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: 30 * _loopCount,
            onPageChanged: (index) {
              setState(() => _currentJuz = index % 30 + 1);
            },
            itemBuilder: (context, index) {
              final juz = index % 30 + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _JuzPage(
                  juz: juz,
                  tested: widget.testedJuz.contains(juz),
                  pageStatus: _pageStatus,
                  onPageTap: (page) => _showPageTasmi(context, page),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// One horizontally-paged juz: header (number + test status) + quran grid.
class _JuzPage extends StatelessWidget {
  const _JuzPage({
    required this.juz,
    required this.tested,
    required this.pageStatus,
    required this.onPageTap,
  });

  final int juz;
  final bool tested;
  final Map<int, ({int? rating, double progress})> pageStatus;
  final ValueChanged<int> onPageTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'الجزء $juz',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.info,
                ),
              ),
            ),
            const Spacer(),
            StatusBadge(
              label: tested ? 'مختبر' : 'غير مختبَر بعد',
              color: tested ? tokens.brand : tokens.textMuted,
              icon: tested ? Icons.check_circle : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 10
                  : constraints.maxWidth >= 550
                  ? 7
                  : 5;
              return QuranGrid(
                juz: juz,
                pageStatus: pageStatus,
                columns: columns,
                onPageTap: onPageTap,
              );
            },
          ),
        ),
      ],
    );
  }
}
