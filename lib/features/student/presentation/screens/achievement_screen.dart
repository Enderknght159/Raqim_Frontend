import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/student_local_repository.dart';
import '../../domain/models/student_models.dart';
import '../student_shell.dart';

/// B3 — التحصيل: general average + subjects + matn + recent exams.
class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

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
          return _AchievementBody(
            data: snapshot.data!,
            repo: repo,
          );
        },
      ),
    );
  }

  Future<_AchievementData> _load(StudentLocalRepository repo) async {
    final examRows = await repo.examsWithSubmissions();
    final matns = await repo.matns();
    final matnRec = await repo.latestMatnRecitations();
    return _AchievementData(
      examRows: examRows,
      matns: matns,
      latestMatn: matnRec,
    );
  }
}

class _AchievementData {
  const _AchievementData({
    required this.examRows,
    required this.matns,
    required this.latestMatn,
  });

  final List<({Exam exam, ExamSubmission? submission})> examRows;
  final List<Matn> matns;
  final Map<int, MatnRecitation> latestMatn;
}

class _AchievementBody extends StatelessWidget {
  const _AchievementBody({required this.data, required this.repo});

  final _AchievementData data;
  final StudentLocalRepository repo;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final subjects = _subjectResults();
    final average =
        subjects.isEmpty ? null : _average(subjects);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero — general average.
        AppCard(
          color: tokens.infoTint,
          borderColor: tokens.infoLight.withValues(alpha: 0.4),
          child: Row(
            children: [
              const IconTile(icon: Icons.workspace_premium,
                  color: Color(0xFF004C69), size: 48, iconSize: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      average == null ? '—' : '$average%',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color:
                                average == null || average < 50
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
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: tokens.textMuted),
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
                  child: Text('لم تشارك في اختبارات بعد',
                      style: Theme.of(context).textTheme.bodyMedium),
                )
              else
                for (final s in subjects)
                  InkWell(
                    onTap: () => _showSubject(context, s.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(s.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700))),
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
                          Icon(Icons.chevron_left, color: tokens.borderStructural),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(icon: Icons.auto_awesome, title: 'المتون'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (data.matns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('لا متون مسجلة',
                      style: Theme.of(context).textTheme.bodyMedium),
                )
              else
                for (final matn in data.matns)
                  _MatnRow(matn: matn, latest: data.latestMatn[matn.id]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(icon: Icons.assignment_outlined, title: 'آخر الاختبارات'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final row in data.examRows.take(3))
                _ExamRow(row: row, tokens: tokens),
              if (data.examRows.length > 3)
                TextButton(
                  onPressed: () => _showAllExams(context),
                  child: Text('عرض المزيد (${data.examRows.length})',
                      style: TextStyle(color: tokens.brandText)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<({String name, int? result})> _subjectResults() {
    final bySubject = <String, List<({Exam exam, ExamSubmission? submission})>>{};
    for (final row in data.examRows) {
      bySubject.putIfAbsent(row.exam.subjectName, () => []).add(row);
    }
    final results = <({String name, int? result})>[];
    bySubject.forEach((name, rows) {
      // Subject result = highest FINAL exam mark.
      int? best;
      for (final row in rows) {
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

  void _showSubject(BuildContext context, String name) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final rows = data.examRows
        .where((r) => r.exam.subjectName == name)
        .toList();
    showModalBottomSheet<void>(
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
            Text('$name — كل التقديمات',
                style: Theme.of(context).textTheme.titleLarge),
            for (final row in rows)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_note,
                    color: row.exam.type == ExamType.finalExam
                        ? tokens.brand
                        : tokens.infoLight),
                title: Text(row.exam.type.arabic),
                subtitle: Text(formatDate(row.exam.date)),
                trailing: Text(
                  row.submission == null
                      ? '—'
                      : '${row.submission!.mark}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: row.submission == null
                        ? tokens.textMuted
                        : tokens.info,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllExams(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    showModalBottomSheet<void>(
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
            for (final row in data.examRows)
              _ExamRow(row: row, tokens: tokens),
          ],
        ),
      ),
    );
  }
}

class _MatnRow extends StatelessWidget {
  const _MatnRow({required this.matn, required this.latest});

  final Matn matn;
  final MatnRecitation? latest;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final reached = latest?.lastVerse ?? 0;
    final percent =
        matn.totalVerses == 0 ? 0.0 : reached / matn.totalVerses;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(matn.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Text('$reached / ${matn.totalVerses}',
                  style: TextStyle(color: tokens.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ProgressBar(
            value: percent,
            color: tokens.accentMatn,
            height: 6,
          ),
        ],
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  const _ExamRow({required this.row, required this.tokens});

  final ({Exam exam, ExamSubmission? submission}) row;
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
      subtitle: Text(
          '${row.exam.type.arabic} · ${formatDate(row.exam.date)}'),
      trailing: Text(
        row.submission == null ? '—' : '${row.submission!.mark}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: row.submission == null
              ? tokens.textMuted
              : tokens.info,
        ),
      ),
    );
  }
}