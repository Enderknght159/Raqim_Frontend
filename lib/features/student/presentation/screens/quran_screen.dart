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
import '../widgets/quran_map.dart';
import '../widgets/rating_stars.dart';
import '../widgets/tasmi_log_sheet.dart';

/// B2 — القرآن: stats + map of the whole mushaf (juz-paged) + certificates +
/// tasmi' log.
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  Future<_QuranData>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load(StudentRepositoryScope.of(context));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_QuranData>(
        future: _future,
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
}

class _QuranData {
  const _QuranData({
    required this.stats,
    required this.memorizations,
    required this.certificates,
    required this.testedJuz,
  });

  final QuranStats stats;
  final List<Memorization> memorizations;
  final List<Certificate> certificates;
  final Set<int> testedJuz;
}

class _QuranBody extends StatelessWidget {
  const _QuranBody({required this.data});

  final _QuranData data;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
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
        QuranMap(
          memorizations: data.memorizations,
          testedJuz: data.testedJuz,
        ),
        const SizedBox(height: 16),
        const SectionHeader(
            icon: Icons.emoji_events_outlined, title: 'شهادات القرآن'),
        const SizedBox(height: 10),
        _certificatesCard(context, tokens),
        const SizedBox(height: 16),
        const SectionHeader(icon: Icons.history, title: 'سجل التسميع'),
        const SizedBox(height: 10),
        _tasmiPreview(context, tokens),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Stats (motivational) ────────────────────────────────────────────────

  Widget _statsSection(BuildContext context, AppTokens tokens) {
    final stats = data.stats;
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

  Widget _certificatesCard(BuildContext context, AppTokens tokens) {
    final certs = data.certificates;
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
            'الأجزاء المختبرة: ${data.testedJuz.length} من 30',
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

  Widget _tasmiPreview(BuildContext context, AppTokens tokens) {
    final mems = data.memorizations;
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
              onPressed: () => showTasmiLogSheet(context, mems),
              child: Text('عرض المزيد (${rows.length})',
                  style: TextStyle(color: tokens.brandText)),
            ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
