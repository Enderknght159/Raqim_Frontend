import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../student/domain/models/student_models.dart';

/// Icon-first attendance status pill: the Arabic word is only revealed on
/// hover (desktop) or long press (touch), keeping session rows uncluttered.
class AttendanceStatusChip extends StatelessWidget {
  const AttendanceStatusChip({
    super.key,
    required this.category,
    this.count,
    this.dense = false,
  });

  final AttendanceCategory category;
  final int? count;
  final bool dense;

  static String labelOf(AttendanceCategory category) => switch (category) {
    AttendanceCategory.early => 'مبكر',
    AttendanceCategory.onTime => 'في الوقت',
    AttendanceCategory.late => 'متأخر',
    AttendanceCategory.absent => 'غائب',
  };

  static IconData iconOf(AttendanceCategory category) => switch (category) {
    AttendanceCategory.early => Icons.wb_sunny_outlined,
    AttendanceCategory.onTime => Icons.schedule,
    AttendanceCategory.late => Icons.timer_off_outlined,
    AttendanceCategory.absent => Icons.person_off_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final color = switch (category) {
      AttendanceCategory.early => tokens.brandText,
      AttendanceCategory.onTime => tokens.infoLight,
      AttendanceCategory.late => tokens.dangerText,
      AttendanceCategory.absent => tokens.textMuted,
    };
    final label = labelOf(category);
    final icon = iconOf(category);
    return Tooltip(
      message: label,
      triggerMode: TooltipTriggerMode.longPress,
      waitDuration: const Duration(milliseconds: 250),
      child: Semantics(
        label: label,
        button: false,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 7 : 9,
            vertical: dense ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: dense ? 14 : 15, color: color),
              if (count != null) ...[
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
