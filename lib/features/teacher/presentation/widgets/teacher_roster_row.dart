import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../admin/domain/admin_models.dart';
import '../../domain/teacher_models.dart';

/// One student row in the teacher's daily roster: attendance toggle, permitted
/// record chips, and a quick view entry.
class TeacherRosterRow extends StatelessWidget {
  const TeacherRosterRow({
    super.key,
    required this.entry,
    required this.attendance,
    required this.records,
    required this.onOpen,
    required this.onToggleAttendance,
    required this.onRecord,
    this.attendanceBusy = false,
  });

  final TeacherRosterEntry entry;
  final AdminAttendanceRow? attendance;
  final List<AdminSessionRecord> records;
  final VoidCallback onOpen;
  final VoidCallback onToggleAttendance;
  final ValueChanged<TeacherRecordKind> onRecord;
  final bool attendanceBusy;

  bool get _present => attendance != null;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final hasRecord = records.isNotEmpty;
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
                    if (hasRecord)
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: tokens.brandText,
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
                        AppChip(
                          label: kind.label,
                          icon: _icon(kind),
                          color: _color(kind, tokens),
                          onTap: () => onRecord(kind),
                        ),
                    ],
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

  IconData _icon(TeacherRecordKind kind) => switch (kind) {
    TeacherRecordKind.quranTasmi => Icons.auto_stories_outlined,
    TeacherRecordKind.matn => Icons.menu_book_outlined,
    TeacherRecordKind.points => Icons.stars_outlined,
    TeacherRecordKind.attendance => Icons.how_to_reg_outlined,
  };

  Color _color(TeacherRecordKind kind, AppTokens tokens) => switch (kind) {
    TeacherRecordKind.quranTasmi => tokens.brand,
    TeacherRecordKind.matn => tokens.accentMatn,
    TeacherRecordKind.points => tokens.reward,
    TeacherRecordKind.attendance => tokens.info,
  };
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
