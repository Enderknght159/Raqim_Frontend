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

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFor(category, tokens),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
