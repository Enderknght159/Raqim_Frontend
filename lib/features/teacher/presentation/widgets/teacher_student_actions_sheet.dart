import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin/domain/admin_models.dart';
import '../../domain/teacher_models.dart';

/// Second write entry point: the teacher taps a student and records for that
/// student directly (attendance + permitted record types).
Future<void> showTeacherStudentActionsSheet(
  BuildContext context, {
  required TeacherRosterEntry entry,
  required AdminAttendanceRow? attendance,
  required List<AdminSessionRecord> records,
  required Future<void> Function() onToggleAttendance,
  required ValueChanged<TeacherRecordKind> onRecord,
  required VoidCallback onShowRecords,
  required ValueChanged<DateTime?> onAdjustAttendanceTime,
  required VoidCallback onOpenProfile,
}) {
  return showAppSheet<void>(
    context: context,
    maxWidth: 560,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _TeacherStudentActionsSheet(
      entry: entry,
      attendance: attendance,
      records: records,
      onToggleAttendance: onToggleAttendance,
      onRecord: onRecord,
      onShowRecords: onShowRecords,
      onAdjustAttendanceTime: onAdjustAttendanceTime,
      onOpenProfile: onOpenProfile,
    ),
  );
}

class _TeacherStudentActionsSheet extends StatefulWidget {
  const _TeacherStudentActionsSheet({
    required this.entry,
    required this.attendance,
    required this.records,
    required this.onToggleAttendance,
    required this.onRecord,
    required this.onShowRecords,
    required this.onAdjustAttendanceTime,
    required this.onOpenProfile,
  });

  final TeacherRosterEntry entry;
  final AdminAttendanceRow? attendance;
  final List<AdminSessionRecord> records;
  final Future<void> Function() onToggleAttendance;
  final ValueChanged<TeacherRecordKind> onRecord;
  final VoidCallback onShowRecords;
  final ValueChanged<DateTime?> onAdjustAttendanceTime;
  final VoidCallback onOpenProfile;

  @override
  State<_TeacherStudentActionsSheet> createState() =>
      _TeacherStudentActionsSheetState();
}

class _TeacherStudentActionsSheetState
    extends State<_TeacherStudentActionsSheet> {
  late bool _present = widget.attendance != null;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final entry = widget.entry;
    final summary = TeacherSessionSummary.fromRecords(widget.records);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: tokens.brandTint,
                  child: Text(
                    entry.student.name.isEmpty
                        ? '?'
                        : entry.student.name.characters.first,
                    style: TextStyle(
                      color: tokens.brandText,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.student.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          entry.typeNames,
                          entry.teamNames,
                        ].where((s) => s.trim().isNotEmpty).join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.attendanceAllowed)
                  StatusBadge(
                    label: _present
                        ? (widget.attendance?.arrivalTime == null
                              ? 'حاضر'
                              : 'حاضر · ${formatTime(widget.attendance!.arrivalTime!)}')
                        : 'غائب',
                    color: _present ? tokens.brand : tokens.textMuted,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (entry.attendanceAllowed) ...[
              AppButton(
                label: _busy
                    ? 'جارٍ الحفظ…'
                    : _present
                    ? 'إلغاء تسجيل الحضور'
                    : 'تسجيل حاضر',
                icon: _present
                    ? Icons.person_remove_alt_1_outlined
                    : Icons.how_to_reg_outlined,
                variant: _present
                    ? AppButtonVariant.secondary
                    : AppButtonVariant.primary,
                loading: _busy,
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        try {
                          await widget.onToggleAttendance();
                          if (!mounted) return;
                          setState(() => _present = !_present);
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
              ),
              if (_present)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: _busy
                        ? null
                        : () => widget.onAdjustAttendanceTime(
                            widget.attendance?.arrivalTime,
                          ),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('تعديل وقت الحضور'),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            if (entry.recordKinds.isNotEmpty) ...[
              Text(
                'إضافة سجل',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in entry.recordKinds)
                    _KindActionChip(
                      label: 'إضافة ${kind.label}',
                      icon: _icon(kind),
                      color: _colorFor(kind, tokens),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onRecord(kind);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (!entry.canWriteAnything)
              AppCard(
                color: tokens.surfaceSubtle,
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: tokens.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'قراءة فقط — لا يمنح نوع حلقتك كتابة سجلات لهذا الطالب.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.records.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'سجلات هذه الجلسة',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onShowRecords();
                    },
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (summary.pages > 0)
                    _SummaryChip(
                      icon: Icons.auto_stories_outlined,
                      label: summary.pagesLabel,
                      color: tokens.brand,
                    ),
                  if (summary.matnLabel != null)
                    _SummaryChip(
                      icon: Icons.menu_book_outlined,
                      label: summary.matnLabel!,
                      color: tokens.accentMatn,
                    ),
                  if (summary.pointsLabel != null)
                    _SummaryChip(
                      icon: Icons.stars_outlined,
                      label: summary.pointsLabel!,
                      color: tokens.reward,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              for (final record in widget.records.take(6))
                _RecordLine(record: record, tokens: tokens),
              if (widget.records.length > 6)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onShowRecords();
                    },
                    child: Text(
                      'عرض بقية السجلات (${widget.records.length - 6})',
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: 'فتح الملف الكامل',
              icon: Icons.open_in_new,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                Navigator.of(context).pop();
                widget.onOpenProfile();
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(TeacherRecordKind kind) => switch (kind) {
    TeacherRecordKind.attendance => Icons.how_to_reg_outlined,
    TeacherRecordKind.quranTasmi => Icons.auto_stories_outlined,
    TeacherRecordKind.matn => Icons.menu_book_outlined,
    TeacherRecordKind.points => Icons.stars_outlined,
  };

  Color _colorFor(TeacherRecordKind kind, AppTokens tokens) => switch (kind) {
    TeacherRecordKind.attendance => tokens.info,
    TeacherRecordKind.quranTasmi => tokens.brand,
    TeacherRecordKind.matn => tokens.accentMatn,
    TeacherRecordKind.points => tokens.reward,
  };
}

/// Compact tinted action with an explicit plus icon, replacing the old
/// full-width secondary buttons.
class _KindActionChip extends StatelessWidget {
  const _KindActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: color),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
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

class _RecordLine extends StatelessWidget {
  const _RecordLine({required this.record, required this.tokens});

  final AdminSessionRecord record;
  final AppTokens tokens;

  IconData get _icon => switch (record.kind) {
    'memorization' => Icons.auto_stories_outlined,
    'matn' => Icons.menu_book_outlined,
    'transaction' => Icons.stars_outlined,
    _ => Icons.receipt_long_outlined,
  };

  Color get _color => switch (record.kind) {
    'memorization' => tokens.brand,
    'matn' => tokens.accentMatn,
    'transaction' => tokens.reward,
    _ => tokens.info,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(_icon, size: 16, color: _color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (record.subtitle.isNotEmpty)
                  Text(
                    record.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatTime(record.when),
            textDirection: TextDirection.ltr,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}
