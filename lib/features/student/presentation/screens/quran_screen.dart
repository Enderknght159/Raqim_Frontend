import 'package:flutter/material.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/student_models.dart';
import '../../domain/quran_units.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/certificates_sheet.dart';
import '../widgets/quran_map.dart';
import '../widgets/rating_stars.dart';
import '../widgets/section_memo.dart';
import '../widgets/tasmi_log_sheet.dart';

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

typedef _QuranMapData = ({List<Memorization> memorizations, Set<int> testedJuz});

/// B2 — القرآن: stats + map of the whole mushaf (juz-paged) + certificates +
/// tasmi' log.
///
/// The page shell, every section header and the fast cards paint immediately;
/// the stats, the mushaf map, the certificates and the tasmi' log each load in
/// their own [AsyncSection], so a slow map query never hides the rest.
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  /// Bumped by pull-to-refresh so every section refetches.
  int _revision = 0;

  SectionMemo<List<Memorization>>? _memorizations;
  SectionMemo<List<Certificate>>? _certificates;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_memorizations != null) return;
    final repo = StudentRepositoryScope.of(context);
    _memorizations = SectionMemo(repo.allMemorizations);
    _certificates = SectionMemo(repo.certificates);
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _revision++);
  }

  /// Map + certificates share the certificate request through the memo.
  Future<_QuranMapData> _loadMap() async {
    // A certificates failure must not hide the map: it only drops the
    // «مختبر» overlay, while the certificates card reports its own error.
    final certsF = _certificates!(_revision).then<List<Certificate>>(
      (certs) => certs,
      onError: (Object _, StackTrace _) => const <Certificate>[],
    );
    final results = await Future.wait<Object>([
      _memorizations!(_revision),
      certsF,
    ]);
    final certs = results[1] as List<Certificate>;
    return (
      memorizations: results[0] as List<Memorization>,
      testedJuz: _testedJuz(certs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            AsyncSection<QuranStats>(
              cacheKey: 'student-quran-stats',
              revision: _revision,
              load: repo.quranStats,
              skeleton: const _StatsSkeleton(),
              builder: (context, stats) => _StatsSection(stats: stats),
            ),
            const SizedBox(height: 14),
            const SectionHeader(icon: Icons.map_outlined, title: 'خريطة الحفظ'),
            const SizedBox(height: 8),
            AsyncSection<_QuranMapData>(
              cacheKey: 'student-quran-map',
              revision: _revision,
              delay: const Duration(milliseconds: 60),
              load: _loadMap,
              skeleton: const SectionSkeleton(height: 240, lines: 1),
              builder: (context, data) {
                if (data.memorizations.isEmpty) {
                  return const EmptyState(
                    title: 'ابدأ رحلتك!',
                    icon: Icons.rocket_launch,
                    message: 'لم تسجّل أي صفحات بعد',
                  );
                }
                return QuranMap(
                  memorizations: data.memorizations,
                  testedJuz: data.testedJuz,
                );
              },
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.emoji_events_outlined,
              title: 'شهادات القرآن',
            ),
            const SizedBox(height: 10),
            AsyncSection<List<Certificate>>(
              cacheKey: 'student-quran-certificates',
              revision: _revision,
              delay: const Duration(milliseconds: 100),
              load: () => _certificates!(_revision),
              skeleton: const SectionSkeleton(height: 84, lines: 2),
              builder: (context, certs) =>
                  _CertificatesCard(certs: certs, testedJuz: _testedJuz(certs)),
            ),
            const SizedBox(height: 16),
            const SectionHeader(icon: Icons.history, title: 'سجل التسميع'),
            const SizedBox(height: 10),
            AsyncSection<List<Memorization>>(
              cacheKey: 'student-quran-tasmi',
              revision: _revision,
              delay: const Duration(milliseconds: 140),
              load: () => _memorizations!(_revision),
              skeleton: const SectionSkeleton(height: 60, lines: 1),
              builder: (context, mems) => _TasmiCard(memorizations: mems),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Stats (motivational) ──────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final QuranStats stats;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      children: [
        // Two adjacent cards: khitmah (date is the hero) + monthly rate.
        Row(
          children: [
            Expanded(child: _khatmCard(context, tokens)),
            const SizedBox(width: 10),
            Expanded(child: _rateCard(context, tokens)),
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
                  // Expanded (not Flexible + Spacer): the label takes all the
                  // leftover width instead of half of it, so it is never
                  // ellipsised early on a 390px phone.
                  Expanded(
                    child: Text(
                      'نسبة إتمام الحفظ للقرآن كاملًا',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _khatmCard(BuildContext context, AppTokens tokens) {
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            stats.expectedCompletion == null
                ? '—'
                : _fmtDate(stats.expectedCompletion!),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: tokens.info,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rateCard(BuildContext context, AppTokens tokens) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.trending_up, size: 22, color: Color(0xFF00A572)),
          const SizedBox(height: 6),
          Text(
            'معدل الحفظ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
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
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'صفحة/شهر',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: SectionSkeleton(height: 34, lines: 1)),
            SizedBox(width: 10),
            Expanded(child: SectionSkeleton(height: 34, lines: 1)),
          ],
        ),
        SizedBox(height: 10),
        SectionSkeleton(height: 34, lines: 1),
      ],
    );
  }
}

// ── Certificates ──────────────────────────────────────────────────────────

class _CertificatesCard extends StatelessWidget {
  const _CertificatesCard({required this.certs, required this.testedJuz});

  final List<Certificate> certs;
  final Set<int> testedJuz;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final entries = <CertificateEntry>[
      for (final c in certs)
        (
          startJuz: c.startJuz,
          endJuz: c.endJuz,
          mark: c.mark,
          byHeart: c.byHeart,
          date: c.date,
        ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (certs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لا شهادات بعد — ركز على الاختبار القادم',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            // Preview: the 3 latest — «عرض الكل» opens the full list.
            for (final c in certs.take(3))
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
                          Text(
                            'الجزء ${c.startJuz} – ${c.endJuz}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'الدرجة: ${c.mark}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.textMuted),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: c.byHeart ? 'عن ظهر قلب' : 'عن حاضر',
                      color: c.byHeart ? tokens.brand : tokens.textMuted,
                    ),
                  ],
                ),
              ),
          if (certs.isNotEmpty)
            Center(
              child: TextButton(
                onPressed: () => showCertificatesSheet(context, entries),
                child: Text(
                  'عرض الكل (${certs.length})',
                  style: TextStyle(color: tokens.brandText),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'الأجزاء المختبرة: ${testedJuz.length} من 30',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Tasmi' log ─────────────────────────────────────────────────────────────

class _TasmiCard extends StatelessWidget {
  const _TasmiCard({required this.memorizations});

  final List<Memorization> memorizations;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final mems = memorizations;
    final rows = mems
        .map(
          (m) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                // Icon + number: «صفحة» is not repeated on every row.
                Tooltip(
                  message: 'رقم الصفحة',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        size: 14,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${m.page}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    quranDisplaySurah(m.page, m.partIndex, m.surah),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                RatingStars(rating: m.rating),
              ],
            ),
          ),
        )
        .toList();
    return AppCard(
      child: Column(
        children: [
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لم تسجّل أي صفحات بعد',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final r in rows.take(3)) r,
          if (rows.length > 3)
            TextButton(
              onPressed: () => showTasmiLogSheet(context, mems),
              child: Text(
                'عرض المزيد (${rows.length})',
                style: TextStyle(color: tokens.brandText),
              ),
            ),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
