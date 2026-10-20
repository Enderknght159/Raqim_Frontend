import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/sparkline.dart';
import '../../domain/models/student_models.dart';
import '../../domain/student_stats.dart';
import 'attendance_day_cell.dart';
import 'points_meter_row.dart';
import 'rating_stars.dart';

/// The student's full achievement inside one course (B1x content): points,
/// attendance, tasmi', matn and the leaderboard. Reused by the student course
/// detail screen and by the admin student profile (E7 → course tap).
class CourseAchievementView extends StatelessWidget {
  const CourseAchievementView({
    super.key,
    required this.bundle,
    required this.leaderboard,
    this.padding = const EdgeInsets.all(16),
  });

  final StudentCourseBundle bundle;
  final List<StudentLeaderboardEntry> leaderboard;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final course = bundle.course;

    return ListView(
      padding: padding,
      children: [
        // Header
        Text(
          course.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: tokens.info,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${formatDate(course.startDate)} – ${formatDate(course.endDate)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: course.isActive ? 'نشطة' : 'منتهية',
              color: course.isActive ? tokens.brand : tokens.textMuted,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Points hero
        _PointsCard(bundle: bundle),
        const SizedBox(height: 12),

        // Attendance
        _AttendanceCard(bundle: bundle),
        const SizedBox(height: 12),

        // Tasmi'
        _TasmiCard(bundle: bundle),
        const SizedBox(height: 12),

        // Matn
        _MatnCard(bundle: bundle),
        const SizedBox(height: 12),

        // Leaderboard
        _LeaderboardCard(entries: leaderboard),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.bundle});

  final StudentCourseBundle bundle;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final b = bundle.breakdown;
    final series = bundle.cumulativeSeries();
    return AppCard(
      onTap: () => _showBreakdown(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${b.total}',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: b.total < 0
                                    ? tokens.danger
                                    : tokens.rewardText,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'نقطة',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: tokens.rewardText),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'متاح للشراء: ${b.purchaseBalance}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
              if (series.length >= 2)
                SizedBox(
                  width: 120,
                  height: 48,
                  child: Sparkline(values: series, color: tokens.reward),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBreakdown(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final b = bundle.breakdown;
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
            Text('تفصيل المحصلة', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            PointsMeterRow(label: 'الحضور', value: b.attendance, color: tokens.info),
            PointsMeterRow(label: 'الحفظ', value: b.memorization, color: tokens.brand),
            PointsMeterRow(label: 'الامتحانات', value: b.exams, color: tokens.accentMatn),
            PointsMeterRow(label: 'الشهادات', value: b.certificates, color: tokens.reward),
            PointsMeterRow(label: 'المتون', value: b.matn, color: tokens.infoLight),
            PointsMeterRow(label: 'مكافأة', value: b.reward, color: tokens.brand),
            PointsMeterRow(label: 'عقوبة', value: -b.penalty, color: tokens.danger),
            PointsMeterRow(label: 'شراء', value: -b.purchase, color: tokens.danger),
            PointsMeterRow(label: 'تحصيل', value: b.collection, color: tokens.brand),
            PointsMeterRow(label: 'دخل صرف', value: b.incomeExpense, color: tokens.info),
            const Divider(),
            Text('المعاملات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            if (bundle.transactions.isEmpty)
              Text('لا توجد معاملات',
                  style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final t in bundle.transactions)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_txIcon(t.type),
                      color: _txColor(t.type, tokens), size: 20),
                  title: Text(t.type.arabic),
                  subtitle: t.description == null
                      ? null
                      : Text(
                          t.description!,
                          style: TextStyle(color: tokens.textMuted, fontSize: 13),
                        ),
                  trailing: Text(
                    _txSigned(t.type, t.pointsValue),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _txColor(t.type, tokens),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.bundle});

  final StudentCourseBundle bundle;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final summary = bundle.attendanceSummary;
    final attBySession = {
      for (final a in bundle.attendance) a.sessionId: a,
    };
    return AppCard(
      onTap: () => _showDays(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'الحضور %${summary.percentage}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_left, color: tokens.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusBadge(label: 'مبكر ${summary.early}', color: tokens.brand),
              StatusBadge(label: 'في الوقت ${summary.onTime}', color: tokens.infoLight),
              StatusBadge(label: 'متأخر ${summary.late}', color: tokens.danger),
              StatusBadge(label: 'غياب ${summary.absent}', color: tokens.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              for (final s in bundle.sessions)
                AttendanceDayCell(category: _categoryOf(s, attBySession)),
            ],
          ),
        ],
      ),
    );
  }

  AttendanceCategory _categoryOf(Session s, Map<int, AttendanceRecord> map) {
    final a = map[s.id];
    if (a?.arrivalTime == null) return AttendanceCategory.absent;
    return s.categoryFor(a!.arrivalTime!);
  }

  void _showDays(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final attBySession = {for (final a in bundle.attendance) a.sessionId: a};
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
            Text('سجل الحضور اليومي',
                style: Theme.of(context).textTheme.titleLarge),
            for (final s in bundle.sessions)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  switch (_categoryOf(s, attBySession)) {
                    AttendanceCategory.early => Icons.schedule,
                    AttendanceCategory.onTime => Icons.check_circle_outline,
                    AttendanceCategory.late => Icons.alarm,
                    AttendanceCategory.absent => Icons.remove_circle_outline,
                  },
                  color: switch (_categoryOf(s, attBySession)) {
                    AttendanceCategory.early => tokens.brand,
                    AttendanceCategory.onTime => tokens.infoLight,
                    AttendanceCategory.late => tokens.danger,
                    AttendanceCategory.absent => tokens.textMuted,
                  },
                ),
                title: Text(formatDate(s.date)),
                trailing: Text(
                  _labelFor(s, attBySession),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: switch (_categoryOf(s, attBySession)) {
                      AttendanceCategory.absent => tokens.textMuted,
                      _ => tokens.textPrimary,
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _labelFor(Session s, Map<int, AttendanceRecord> map) {
    final a = map[s.id];
    if (a?.arrivalTime == null) return 'غائب';
    return switch (s.categoryFor(a!.arrivalTime!)) {
      AttendanceCategory.early => 'مبكر ${formatTime(a.arrivalTime!)}',
      AttendanceCategory.onTime => 'في الوقت ${formatTime(a.arrivalTime!)}',
      AttendanceCategory.late => 'متأخر ${formatTime(a.arrivalTime!)}',
      AttendanceCategory.absent => 'غائب',
    };
  }
}

class _TasmiCard extends StatelessWidget {
  const _TasmiCard({required this.bundle});

  final StudentCourseBundle bundle;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final mems = bundle.memorizations;
    return AppCard(
      onTap: () => _showLog(context),
      child: Row(
        children: [
          Icon(Icons.record_voice_over_outlined, color: tokens.brand, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('التسميع', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${mems.length} تسجيلة حفظ',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.textMuted),
        ],
      ),
    );
  }

  void _showLog(BuildContext context) {
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
            Text('سجل التسميع', style: Theme.of(context).textTheme.titleLarge),
            if (bundle.memorizations.isEmpty)
              Text('لا توجد تسجيلات',
                  style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final m in bundle.memorizations)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.menu_book,
                    color: RatingStars.colorFor(m.rating,
                        Theme.of(context).extension<AppTokens>()!),
                  ),
                  title: Text('صفحة ${m.page}'),
                  subtitle: Text('${m.surah} · المسمِّع: ${m.reciterName}'),
                  trailing: RatingStars(rating: m.rating),
                ),
          ],
        ),
      ),
    );
  }
}

class _MatnCard extends StatelessWidget {
  const _MatnCard({required this.bundle});

  final StudentCourseBundle bundle;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final latest = <int, MatnRecitation>{
      for (final r in bundle.matnRecitations) r.matnId: r,
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
              icon: Icons.menu_book, title: 'المتون', color: Color(0xFF7C3AED)),
          const SizedBox(height: 10),
          if (bundle.matns.isEmpty)
            Text('لا توجد متون', style: Theme.of(context).textTheme.bodyMedium)
          else
            for (final matn in bundle.matns)
              _matnRow(context, tokens, matn, latest[matn.id]),
        ],
      ),
    );
  }

  Widget _matnRow(BuildContext context, AppTokens tokens, Matn matn,
      MatnRecitation? latest) {
    final reached = latest?.lastVerse ?? 0;
    final percent = matn.totalVerses == 0
        ? 0.0
        : reached / matn.totalVerses;
    return InkWell(
      onTap: () => _showMatnRecitations(context, matn),
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(matn.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                ),
                Text(
                  '$reached / ${matn.totalVerses} بيت',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_left, size: 16, color: tokens.borderStructural),
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
      ),
    );
  }

  /// Latest tasmi' records of this matn within this course.
  void _showMatnRecitations(BuildContext context, Matn matn) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final sessionById = {
      for (final s in bundle.sessions) s.id: s,
    };
    final records = bundle.matnRecitations
        .where((r) => r.matnId == matn.id)
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
            Text('${matn.name} — التسميعات في هذه الدورة',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Text('لا توجد تسميعات لهذا المتن في هذه الدورة',
                  style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final r in records)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.menu_book, color: tokens.accentMatn),
                  title: Text('البيت الأخير: ${r.lastVerse}'),
                  subtitle: Text(
                      '${r.teacherName} · '
                      '${formatDate(sessionById[r.sessionId]?.date ?? DateTime.now())}'),
                ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.entries});

  final List<StudentLeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
              icon: Icons.leaderboard, title: 'الطلاب الأوائل'),
          const SizedBox(height: 2),
          Text(
            'ترتيب الطلاب على هذه الدورة',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Text('لا يوجد طلاب بعد',
                style: Theme.of(context).textTheme.bodyMedium)
          else
            for (final e in entries)
              _LeaderboardRow(entry: e),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final StudentLeaderboardEntry entry;

  /// 1st gold → 2nd lighter gold → 3rd near-gray; the rest plain.
  (Color? color, Color? border) _highlight(AppTokens tokens) {
    switch (entry.rank) {
      case 1:
        return (tokens.reward.withValues(alpha: 0.18),
            tokens.reward.withValues(alpha: 0.7));
      case 2:
        return (tokens.reward.withValues(alpha: 0.10),
            tokens.reward.withValues(alpha: 0.4));
      case 3:
        return (tokens.surfaceSubtle, tokens.borderStructural);
      default:
        return (null, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final (tint, border) = _highlight(tokens);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tint ?? tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: border == null
            ? null
            : Border.all(color: border, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: entry.rank <= 3
                        ? tokens.rewardText
                        : tokens.textMuted,
                  ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: tokens.brandTint,
            child: Text(
              entry.student.name.characters.first,
              style: TextStyle(
                  color: tokens.brandText,
                  fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.student.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${entry.points}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: tokens.rewardText,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            'نقطة',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}

IconData _txIcon(TransactionType t) => switch (t) {
      TransactionType.reward => Icons.add_circle_outline,
      TransactionType.penalty => Icons.remove_circle_outline,
      TransactionType.purchase => Icons.shopping_bag_outlined,
      TransactionType.collection => Icons.savings_outlined,
      TransactionType.incomeExpense => Icons.swap_horiz,
    };

Color _txColor(TransactionType t, AppTokens tokens) => switch (t) {
      TransactionType.penalty => tokens.danger,
      TransactionType.purchase => tokens.danger,
      _ => tokens.brand,
    };

String _txSigned(TransactionType t, int value) {
  final v = value.abs();
  return switch (t) {
    TransactionType.reward ||
    TransactionType.collection ||
    TransactionType.incomeExpense =>
      '+$v',
    _ => '-$v',
  };
}
