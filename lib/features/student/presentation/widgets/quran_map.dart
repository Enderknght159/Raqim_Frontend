import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/student_models.dart';
import 'quran_grid.dart';

/// Latest rating per (page,partIndex); per page rating = max rating,
/// progress = covered parts / total parts.
Map<int, ({int? rating, double progress})> computeQuranPageStatus(
    List<Memorization> memorizations) {
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
        rating:
            entry.value.map((m) => m.rating).reduce((a, b) => a > b ? a : b),
        progress: (entry.value.length /
                (entry.value.first.parts <= 0 ? 1 : entry.value.first.parts))
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
    return ((latestPage - 1) ~/ 20 + 1).clamp(1, 30);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick slider: jump instantly between the 30 juz.
        JuzSlider(
          selected: _currentJuz,
          onChanged: _jumpToJuz,
        ),
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
  });

  final int juz;
  final bool tested;
  final Map<int, ({int? rating, double progress})> pageStatus;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'الجزء $juz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.info,
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
          child: QuranGrid(juz: juz, pageStatus: pageStatus, columns: 7),
        ),
      ],
    );
  }
}
