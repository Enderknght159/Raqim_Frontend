import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/student_models.dart';

/// Small colored day cell in the course-attendance grid. Color derives from
/// the attendance category (early/on-time/late/absent).
class AttendanceDayCell extends StatelessWidget {
  const AttendanceDayCell({super.key, required this.category, this.size = 22});

  final AttendanceCategory category;
  final double size;

  static Color colorFor(AttendanceCategory category, AppTokens tokens) =>
      switch (category) {
        AttendanceCategory.early => tokens.brand,
        AttendanceCategory.onTime => tokens.infoLight,
        AttendanceCategory.late => tokens.danger,
        AttendanceCategory.absent => tokens.borderStructural,
      };

  /// Category name — the cell is color-only, so it must never rely on color
  /// alone to carry meaning.
  static String labelFor(AttendanceCategory category) => switch (category) {
    AttendanceCategory.early => 'حضور مبكر',
    AttendanceCategory.onTime => 'حضور في الوقت',
    AttendanceCategory.late => 'حضور متأخر',
    AttendanceCategory.absent => 'غياب',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Tooltip(
      message: labelFor(category),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorFor(category, tokens),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
