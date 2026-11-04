import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
    required this.onOpenProfile,
  });

  final TeacherRosterEntry entry;
  final AdminAttendanceRow? attendance;
  final List<AdminSessionRecord> records;
  final Future<void> Function() onToggleAttendance;
  final ValueChanged<TeacherRecordKind> onRecord;
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
                    label: _present ? 'حاضر' : 'غائب',
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
              const SizedBox(height: 12),
            ],
            if (entry.recordKinds.isNotEmpty) ...[
              Text(
                'إضافة سجل',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (final kind in entry.recordKinds) ...[
                AppButton(
                  label: kind.longLabel,
                  icon: _icon(kind),
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onRecord(kind);
                  },
                ),
                const SizedBox(height: 8),
              ],
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
              Text(
                'سجلات هذه الجلسة',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              for (final record in widget.records)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        _icon(_kindFromRecord(record.kind)),
                        size: 16,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          record.title,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
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

  TeacherRecordKind _kindFromRecord(String kind) => switch (kind) {
    'memorization' => TeacherRecordKind.quranTasmi,
    'matn' => TeacherRecordKind.matn,
    'transaction' => TeacherRecordKind.points,
    _ => TeacherRecordKind.attendance,
  };

  IconData _icon(TeacherRecordKind kind) => switch (kind) {
    TeacherRecordKind.attendance => Icons.how_to_reg_outlined,
    TeacherRecordKind.quranTasmi => Icons.auto_stories_outlined,
    TeacherRecordKind.matn => Icons.menu_book_outlined,
    TeacherRecordKind.points => Icons.stars_outlined,
  };
}
