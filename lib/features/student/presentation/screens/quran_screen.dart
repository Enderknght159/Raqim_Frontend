import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/student_local_repository.dart';
import '../../domain/models/student_models.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/quran_grid.dart';
import '../widgets/rating_stars.dart';

/// B2 — القرآن: stats + horizontally-paged 30-juz map + certificates + tasmi'.
class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      body: FutureBuilder(
        future: _load(repo),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('تعذر التحميل'));
          }
          return _QuranBody(data: snapshot.data!);
        },
      ),
    );
  }

  Future<_QuranData> _load(StudentLocalRepository repo) async {
    final mems = await repo.allMemorizations();
    final stats = await repo.quranStats();
    final certs = await repo.certificates();
    return _QuranData(
      stats: stats,
      memorizations: mems,
      certificates: certs,
      testedJuz: _testedJuz(certs),
      pageStatus: _buildPageStatus(mems),
    );
  }

  /// Juz are considered "tested" when a certificate covers their range.
  Set<int> _testedJuz(List<Certificate> certs) {
    final tested = <int>{};
    for (final c in certs) {
      for (var j = c.startJuz; j <= c.endJuz; j++) {
        tested.add(j);
      }
    }
    return tested;
  }

  /// Latest rating per (page,partIndex); per page rating = max rating,
  /// progress = covered parts / total parts.
  Map<int, ({int? rating, double progress})> _buildPageStatus(
      List<Memorization> mems) {
    final latest = <String, Memorization>{};
    for (final m in mems) {
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
          progress: (entry.value.length /
                  (entry.value.first.parts <= 0 ? 1 : entry.value.first.parts))
              .clamp(0.0, 1.0),
        ),
    };
  }
}

class _QuranData {
  const _QuranData({
    required this.stats,
    required this.memorizations,
    required this.certificates,
    required this.testedJuz,
    required this.pageStatus,
  });

  final QuranStats stats;
  final List<Memorization> memorizations;
  final List<Certificate> certificates;
  final Set<int> testedJuz;
  final Map<int, ({int? rating, double progress})> pageStatus;
}

class _QuranBody extends StatefulWidget {
  const _QuranBody({required this.data});

  final _QuranData data;

  @override
  State<_QuranBody> createState() => _QuranBodyState();
}

class _QuranBodyState extends State<_QuranBody> {
  // A multiple of 30 so `index % 30` always maps to the correct juz — this
  // gives a looping (infinite) page view from juz 30 back to juz 1.
  static const int _basePage = 900;
  static const int _loopCount = 50; // 1500 pages total (50 full cycles).

  late final PageController _controller;
  late int _currentJuz;

  @override
  void initState() {
    super.initState();
    _currentJuz = _computeInitialJuz();
    _controller = PageController(initialPage: _pageFor(_currentJuz));
  }

  int _computeInitialJuz() {
    if (widget.data.memorizations.isEmpty) return 30;
    final latestPage = widget.data.memorizations
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
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final data = widget.data;
    if (data.memorizations.isEmpty) {
      return const EmptyState(
        title: 'ابدأ رحلتك!',
        icon: Icons.rocket_launch,
        message: 'لم تسجّل أي صفحات بعد',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statsSection(context, tokens),
        const SizedBox(height: 14),
        const SectionHeader(icon: Icons.map_outlined, title: 'خريطة الحفظ'),
        const SizedBox(height: 8),
        // Quick slider: jump instantly between the 30 juz.
        JuzSlider(
          selected: _currentJuz,
          onChanged: _jumpToJuz,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
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
                  tested: data.testedJuz.contains(juz),
                  pageStatus: data.pageStatus,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
            icon: Icons.emoji_events_outlined, title: 'شهادات القرآن'),
        const SizedBox(height: 10),
        _certificatesCard(tokens),
        const SizedBox(height: 16),
        const SectionHeader(icon: Icons.history, title: 'سجل التسميع'),
        const SizedBox(height: 10),
        _tasmiPreview(tokens),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Stats (motivational) ────────────────────────────────────────────────

  Widget _statsSection(BuildContext context, AppTokens tokens) {
    final stats = widget.data.stats;
    return Column(
      children: [
        // Two adjacent cards: khitmah (date is the hero) + monthly rate.
        Row(
          children: [
            Expanded(child: _khatmCard(context, tokens, stats)),
            const SizedBox(width: 10),
            Expanded(child: _rateCard(context, tokens, stats)),
          ],
        ),
        const SizedBox(height: 10),
        // Full-Quran progress bar (the only card about overall completion).
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.hourglass_top, size: 16, color: tokens.info),
                  const SizedBox(width: 6),
                  Text(
                    'نسبة إتمام الحفظ للقرآن كاملًا',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '${stats.percent}%',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: tokens.brandText,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(
                value: stats.percent / 100,
                color: tokens.brand,
                height: 10,
              ),
              const SizedBox(height: 6),
              Text(
                '${stats.pagesMemorized} من 604 صفحة',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _khatmCard(BuildContext context, AppTokens tokens, QuranStats stats) {
    return AppCard(
      color: tokens.infoTint,
      borderColor: tokens.infoLight.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag, size: 22, color: Color(0xFF004C69)),
          const SizedBox(height: 6),
          Text(
            'الختم المتوقع',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            stats.expectedCompletion == null
                ? '—'
                : _fmt(stats.expectedCompletion!),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: tokens.info,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }

  Widget _rateCard(BuildContext context, AppTokens tokens, QuranStats stats) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.trending_up, size: 22, color: Color(0xFF00A572)),
          const SizedBox(height: 6),
          Text(
            'معدل الحفظ',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.monthlyRate}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'صفحة/شهر',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Certificates ───────────────────────────────────────────────────────

  Widget _certificatesCard(AppTokens tokens) {
    final certs = widget.data.certificates;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (certs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('لا شهادات بعد — ركز على الاختبار القادم',
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            for (final c in certs)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.school_outlined, color: tokens.reward),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الجزء ${c.startJuz} – ${c.endJuz}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text('الدرجة: ${c.mark}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: tokens.textMuted)),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: c.byHeart ? 'بالغيب' : 'عن ظهر قلب',
                      color: c.byHeart ? tokens.brand : tokens.textMuted,
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 4),
          Text(
            'الأجزاء المختبرة: ${widget.data.testedJuz.length} من 30',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Tasmi' log ─────────────────────────────────────────────────────────

  Widget _tasmiPreview(AppTokens tokens) {
    final mems = widget.data.memorizations;
    final rows = mems
        .map((m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text('صفحة ${m.page}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(
                    m.surah,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: tokens.textMuted),
                  ),
                  const SizedBox(width: 8),
                  RatingStars(rating: m.rating),
                ],
              ),
            ))
        .toList();
    return AppCard(
      child: Column(
        children: [
          for (final r in rows.take(3)) r,
          if (rows.length > 3)
            TextButton(
              onPressed: () => _showFullLog(context),
              child: Text('عرض المزيد (${rows.length})',
                  style: TextStyle(color: tokens.brandText)),
            ),
        ],
      ),
    );
  }

  void _showFullLog(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final mems = widget.data.memorizations;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Text('سجل التسميع',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                StatusBadge(
                    label: '${mems.length} تسجيلة', color: tokens.brand),
              ],
            ),
            const SizedBox(height: 8),
            for (final m in mems)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                    Icons.menu_book,
                    color: RatingStars.colorFor(m.rating, tokens)),
                title: Text('صفحة ${m.page} — ${m.surah}'),
                subtitle: Text('المسمِّع: ${m.reciterName}'),
                trailing: RatingStars(rating: m.rating),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
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