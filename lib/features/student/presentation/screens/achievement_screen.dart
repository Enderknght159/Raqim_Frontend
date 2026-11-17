import 'package:flutter/material.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/models/student_models.dart';
import '../student_shell.dart';
import '../widgets/section_memo.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

typedef _ExamRow = ({Exam exam, ExamSubmission? submission});
typedef _ExamRows = List<_ExamRow>;
typedef _MatnData = ({List<Matn> matns, Map<int, MatnRecitation> latest});

/// B3 — التحصيل: general average + subjects + matn + recent exams.
///
/// The page shell and the section titles paint immediately. The average/
/// subjects block, the matn block and the recent-exams block each load in their
/// own [AsyncSection]; the exam rows are shared through a [SectionMemo], so the
/// endpoint is still called once per revision.
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  /// Bumped by pull-to-refresh so every section refetches.
  int _revision = 0;

  SectionMemo<_ExamRows>? _exams;
  SectionMemo<_MatnData>? _matns;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exams != null) return;
    final repo = StudentRepositoryScope.of(context);
    _exams = SectionMemo(repo.examsWithSubmissions);
    _matns = SectionMemo(() async {
      final results = await Future.wait<Object>([
        repo.matns(),
        repo.latestMatnRecitations(),
      ]);
      return (
        matns: results[0] as List<Matn>,
        latest: results[1] as Map<int, MatnRecitation>,
      );
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePage(
        maxWidth: 1100,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              AsyncSection<_ExamRows>(
                cacheKey: 'student-achievement-summary',
                revision: _revision,
                load: () => _exams!(_revision),
                skeleton: const _SummarySkeleton(),
                builder: (context, rows) => _SummarySection(rows: rows),
              ),
              const SizedBox(height: 16),
              const SectionHeader(icon: Icons.auto_awesome, title: 'المتون'),
              const SizedBox(height: 8),
              AsyncSection<_MatnData>(
                cacheKey: 'student-achievement-matns',
                revision: _revision,
                delay: const Duration(milliseconds: 60),
                load: () => _matns!(_revision),
                skeleton: const SectionSkeleton(height: 72, lines: 2),
                builder: (context, data) => _MatnCard(
                  matns: data.matns,
                  latest: data.latest,
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(
                icon: Icons.assignment_outlined,
                title: 'آخر الاختبارات',
              ),
              const SizedBox(height: 8),
              AsyncSection<_ExamRows>(
                cacheKey: 'student-achievement-exams',
                revision: _revision,
                delay: const Duration(milliseconds: 100),
                load: () => _exams!(_revision),
                skeleton: const SectionSkeleton(height: 64, lines: 2),
                builder: (context, rows) => _ExamsCard(rows: rows),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// General average + subjects, both derived from the same exam rows.
class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.rows});

  final _ExamRows rows;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final subjects = _subjectResults(rows);
    final average = _average(subjects);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero — general average.
        AppCard(
          color: tokens.infoTint,
          borderColor: tokens.infoLight.withValues(alpha: 0.4),
          child: Row(
            children: [
              const IconTile(
                icon: Icons.workspace_premium,
                color: Color(0xFF004C69),
                size: 48,
                iconSize: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      average == null ? '—' : '$average%',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: average == null || average < 50
                                ? tokens.textMuted
                                : tokens.info,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'المعدل العام',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: tokens.info,
                      ),
                    ),
                    Text(
                      'من المواد المختبرة في هذا الدورة',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(icon: Icons.menu_book, title: 'المواد العلمية'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'لم تشارك في اختبارات بعد',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final s in subjects)
                  InkWell(
                    onTap: () => _showSubject(context, s.name, rows),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            s.result == null ? '—' : '${s.result}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: s.result == null
                                  ? tokens.textMuted
                                  : (s.result! >= 50
                                        ? tokens.brandText
                                        : tokens.danger),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_left,
                            color: tokens.borderStructural,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionSkeleton(height: 44, lines: 1),
        SizedBox(height: 16),
        // Keeps the section title on screen while the rows load.
        SectionHeader(icon: Icons.menu_book, title: 'المواد العلمية'),
        SizedBox(height: 8),
        SectionSkeleton(height: 96, lines: 3),
      ],
    );
  }
}

class _MatnCard extends StatelessWidget {
  const _MatnCard({required this.matns, required this.latest});

  final List<Matn> matns;
  final Map<int, MatnRecitation> latest;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (matns.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لا متون مسجلة',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final matn in matns)
              _MatnRow(matn: matn, latest: latest[matn.id]),
        ],
      ),
    );
  }
}

class _ExamsCard extends StatelessWidget {
  const _ExamsCard({required this.rows});

  final _ExamRows rows;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in rows.take(3)) _ExamRowTile(row: row, tokens: tokens),
          if (rows.length > 3)
            TextButton(
              onPressed: () => _showAllExams(context, rows),
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

List<({String name, int? result})> _subjectResults(_ExamRows rows) {
  final bySubject = <String, _ExamRows>{};
  for (final row in rows) {
    bySubject.putIfAbsent(row.exam.subjectName, () => []).add(row);
  }
  final results = <({String name, int? result})>[];
  bySubject.forEach((name, subjectRows) {
    // Subject result = highest FINAL exam mark.
    int? best;
    for (final row in subjectRows) {
      if (row.exam.type == ExamType.finalExam && row.submission != null) {
        final mark = row.submission!.mark.toInt();
        if (best == null || mark > best) best = mark;
      }
    }
    results.add((name: name, result: best));
  });
  return results;
}

int? _average(List<({String name, int? result})> subjects) {
  var sum = 0;
  var count = 0;
  for (final s in subjects) {
    if (s.result != null) {
      sum += s.result!;
      count++;
    }
  }
  return count == 0 ? null : (sum / count).round();
}

void _showSubject(BuildContext context, String name, _ExamRows rows) {
  final tokens = Theme.of(context).extension<AppTokens>()!;
  final subjectRows = rows.where((r) => r.exam.subjectName == name).toList();
  showAppSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            '$name — كل التقديمات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final row in subjectRows)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.edit_note,
                color: row.exam.type == ExamType.finalExam
                    ? tokens.brand
                    : tokens.infoLight,
              ),
              title: Text(row.exam.type.arabic),
              subtitle: Text(formatDate(row.exam.date)),
              trailing: Text(
                row.submission == null ? '—' : '${row.submission!.mark}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: row.submission == null ? tokens.textMuted : tokens.info,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

void _showAllExams(BuildContext context, _ExamRows rows) {
  final tokens = Theme.of(context).extension<AppTokens>()!;
  showAppSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('كل الاختبارات', style: Theme.of(context).textTheme.titleLarge),
          for (final row in rows) _ExamRowTile(row: row, tokens: tokens),
        ],
      ),
    ),
  );
}

class _MatnRow extends StatelessWidget {
  const _MatnRow({required this.matn, required this.latest});

  final Matn matn;
  final MatnRecitation? latest;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final reached = latest?.lastVerse ?? 0;
    final percent = matn.totalVerses == 0 ? 0.0 : reached / matn.totalVerses;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  matn.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$reached / ${matn.totalVerses}',
                style: TextStyle(color: tokens.textMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ProgressBar(value: percent, color: tokens.accentMatn, height: 6),
        ],
      ),
    );
  }
}

class _ExamRowTile extends StatelessWidget {
  const _ExamRowTile({required this.row, required this.tokens});

  final _ExamRow row;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        row.exam.type == ExamType.finalExam
            ? Icons.workspace_premium_outlined
            : Icons.edit_note,
        color: row.exam.type == ExamType.finalExam
            ? tokens.brand
            : tokens.infoLight,
      ),
      title: Text(row.exam.subjectName),
      subtitle: Text('${row.exam.type.arabic} · ${formatDate(row.exam.date)}'),
      trailing: Text(
        row.submission == null ? '—' : '${row.submission!.mark}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: row.submission == null ? tokens.textMuted : tokens.info,
        ),
      ),
    );
  }
}
