import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Open attendance ring: the attended portion is drawn as colored arcs
/// (early/on-time/late) and the **remaining gap expresses absence** — the
/// ring is NOT a closed circle. Centre shows the attendance % + a "حضور" hint.
class AttendanceRing extends StatelessWidget {
  const AttendanceRing({
    super.key,
    required this.early,
    required this.onTime,
    required this.late,
    required this.totalSessions,
    this.radius = 30,
  });

  final int early;
  final int onTime;
  final int late;
  final int totalSessions;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final attended = early + onTime + late;
    final percentage =
        totalSessions == 0 ? 0 : ((attended / totalSessions) * 100).round();

    return SizedBox(
      width: radius * 2 + 12,
      height: radius * 2 + 12,
      child: CustomPaint(
        painter: _OpenRingPainter(
          values: [early, onTime, late],
          colors: [tokens.brand, tokens.infoLight, tokens.danger],
          totalSessions: totalSessions,
          strokeWidth: 7,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
              ),
              Text(
                'حضور',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: tokens.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenRingPainter extends CustomPainter {
  _OpenRingPainter({
    required this.values,
    required this.colors,
    required this.totalSessions,
    required this.strokeWidth,
  });

  final List<int> values;
  final List<Color> colors;
  final int totalSessions;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    if (totalSessions <= 0) return;

    const startAngle = -math.pi / 2; // 12 o'clock
    var current = startAngle;

    for (var i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweep = (values[i] / totalSessions) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = colors[i];
      canvas.drawArc(rect, current, sweep, false, paint);
      current += sweep;
    }
    // The remaining arc is intentionally left OPEN = absence.
  }

  @override
  bool shouldRepaint(_OpenRingPainter old) =>
      old.values != values ||
      old.colors != colors ||
      old.totalSessions != totalSessions;
}