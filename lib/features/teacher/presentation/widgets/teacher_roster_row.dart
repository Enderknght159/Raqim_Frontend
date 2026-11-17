import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../admin/domain/admin_models.dart';
import '../../domain/teacher_models.dart';

/// One student row in the teacher's daily roster: attendance toggle, compact
/// add-record actions, and a summary of everything already recorded today.
class TeacherRosterRow extends StatelessWidget {
  const TeacherRosterRow({
    super.key,
    required this.entry,
    required this.attendance,
    required this.records,
    required this.onOpen,
    required this.onToggleAttendance,
    required this.onRecord,
    required this.onShowRecords,
    this.attendanceBusy = false,
  });

  final TeacherRosterEntry entry;
  final AdminAttendanceRow? attendance;
  final List<AdminSessionRecord> records;
  final VoidCallback onOpen;
  final VoidCallback onToggleAttendance;
  final ValueChanged<TeacherRecordKind> onRecord;
  final VoidCallback onShowRecords;
  final bool attendanceBusy;

  bool get _present => attendance != null;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final summary = TeacherSessionSummary.fromRecords(records);
    final initial = entry.student.name.trim().isEmpty
        ? '?'
        : entry.student.name.trim().characters.first;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: tokens.brandTint,
            child: Text(
              initial,
              style: TextStyle(
                color: tokens.brandText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    if (!summary.isEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 6),
                        child: Tooltip(
                          message: 'سُجّل له في هذه الجلسة',
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: tokens.brandText,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    entry.typeNames,
                    entry.teamNames,
                  ].where((s) => s.trim().isNotEmpty).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                if (entry.recordKinds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final kind in entry.recordKinds)
                        _QuickAddChip(
                          label: kind.label,
                          tooltip: 'إضافة ${kind.label}',
                          icon: Icons.add,
                          color: _color(kind, tokens),
                          onTap: () => onRecord(kind),
                        ),
                    ],
                  ),
                ],
                if (!summary.isEmpty) ...[
                  const SizedBox(height: 8),
                  _SessionSummaryStrip(
                    summary: summary,
                    onTap: onShowRecords,
                    tokens: tokens,
                  ),
                ],
                if (!entry.canWriteAnything) ...[
                  const SizedBox(height: 6),
                  Text(
                    'قراءة فقط',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (entry.attendanceAllowed)
            _AttendanceButton(
              present: _present,
              busy: attendanceBusy,
              onTap: onToggleAttendance,
            ),
        ],
      ),
    );
  }

  Color _color(TeacherRecordKind kind, AppTokens tokens) => switch (kind) {
    TeacherRecordKind.quranTasmi => tokens.brand,
    TeacherRecordKind.matn => tokens.accentMatn,
    TeacherRecordKind.points => tokens.reward,
    TeacherRecordKind.attendance => tokens.info,
  };
}

/// Compact, tinted add action — the plus icon makes the write intent explicit.
class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable strip that answers «ماذا سُجّل لهذا الطالب؟» at a glance and
/// opens the full details on tap.
class _SessionSummaryStrip extends StatelessWidget {
  const _SessionSummaryStrip({
    required this.summary,
    required this.onTap,
    required this.tokens,
  });

  final TeacherSessionSummary summary;
  final VoidCallback onTap;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'عرض سجلات هذه الجلسة',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: tokens.surfaceSubtle,
            borderRadius: BorderRadius.circular(tokens.radiusSmall),
            border: Border.all(color: tokens.borderStructural),
          ),
          child: Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 15, color: tokens.info),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (summary.pages > 0)
                      _SummaryPill(
                        icon: Icons.auto_stories_outlined,
                        label: summary.pagesLabel,
                        color: tokens.brand,
                      ),
                    if (summary.matnLabel != null)
                      _SummaryPill(
                        icon: Icons.menu_book_outlined,
                        label: summary.matnLabel!,
                        color: tokens.accentMatn,
                      ),
                    if (summary.pointsLabel != null)
                      _SummaryPill(
                        icon: Icons.stars_outlined,
                        label: summary.pointsLabel!,
                        color: tokens.reward,
                      ),
                    if (summary.otherCount > 0)
                      _SummaryPill(
                        icon: Icons.receipt_long_outlined,
                        label: '${summary.otherCount} سجل',
                        color: tokens.info,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left, size: 16, color: tokens.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  const _AttendanceButton({
    required this.present,
    required this.busy,
    required this.onTap,
  });

  final bool present;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (busy) {
      return const SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return IconButton(
      tooltip: present ? 'إلغاء الحضور' : 'تسجيل حاضر',
      onPressed: onTap,
      icon: Icon(
        present ? Icons.check_circle : Icons.radio_button_unchecked,
        color: present ? tokens.brand : tokens.textMuted,
      ),
    );
  }
}
