import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/numeral_utils.dart';
import '../../../../core/widgets/metric_charts.dart';

/// Compact icon + number pair used under charts (YouTube-style counters).
/// The label is never rendered as text — it only appears on hover / long press.
class IconCount extends StatelessWidget {
  const IconCount({
    super.key,
    required this.icon,
    required this.value,
    required this.tooltip,
    this.color,
    this.fraction,
    this.valueText,
  });

  final IconData icon;
  final int value;
  final String tooltip;
  final Color? color;

  /// When set, renders «value/fraction» instead of a single number.
  final int? fraction;

  /// Explicit display text (e.g. «12.5/20») overriding the numeric render.
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.textMuted;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 4),
          Text(
            valueText ??
                (fraction == null
                    ? formatNumber(value)
                    : '${formatNumber(value)}/${formatNumber(fraction!)}'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The shared attendance visual block: a donut on the left, an
/// attendance-over-time line on the right, and icon-only counters underneath.
///
/// It deliberately avoids «number on top of a caption» metric stacks; each
/// counter is just an icon and a number so the card stays scannable.
class CourseMetricsPanel extends StatelessWidget {
  const CourseMetricsPanel({
    super.key,
    required this.attendancePercent,
    required this.series,
    required this.studentsCount,
    required this.sessionsCount,
    this.lastPresent,
    this.lastTotal,
    this.chartHeight = 84,
  });

  final int attendancePercent;
  final List<double> series;
  final int studentsCount;
  final int sessionsCount;
  final int? lastPresent;
  final int? lastTotal;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: chartHeight + 8,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // RTL: the first child is on the right, so the chart gets the
              // wider right-hand area and the donut sits on the left.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: AttendanceTrendChart(
                    values: series,
                    height: chartHeight,
                    color: tokens.brand,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Center(
                child: AttendanceDonut(
                  percent: attendancePercent.toDouble(),
                  size: chartHeight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconCount(
              icon: Icons.groups_outlined,
              value: studentsCount,
              tooltip: 'عدد الطلاب',
              color: tokens.infoLight,
            ),
            IconCount(
              icon: Icons.event_note_outlined,
              value: sessionsCount,
              tooltip: 'عدد الجلسات',
              color: tokens.brandText,
            ),
            if (lastPresent != null)
              IconCount(
                icon: Icons.fact_check_outlined,
                value: lastPresent!,
                fraction: lastTotal,
                tooltip: 'حضور آخر جلسة',
                color: tokens.accentMatn,
              ),
          ],
        ),
      ],
    );
  }
}
