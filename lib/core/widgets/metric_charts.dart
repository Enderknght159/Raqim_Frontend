import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular percentage gauge used on summary cards.
///
/// The percentage number is centred inside the ring; the «%» sign is smaller
/// and uses the muted text colour so the value keeps the visual weight.
class PercentDonut extends StatelessWidget {
  const PercentDonut({
    super.key,
    required this.percent,
    this.size = 82,
    this.strokeWidth = 7,
    this.color,
    this.label,
  });

  /// 0–100.
  final double percent;
  final double size;
  final double strokeWidth;
  final Color? color;

  /// Optional caption under the value (kept tiny). Usually null.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brand;
    final value = percent.isFinite ? percent.clamp(0, 100) : 0.0;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          value: value / 100,
          color: accent,
          trackColor: accent.withValues(alpha: 0.13),
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.all(size * 0.16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: value.round().toString(),
                          style: TextStyle(
                            fontSize: size * 0.27,
                            fontWeight: FontWeight.w900,
                            color: tokens.textPrimary,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: '%',
                          style: TextStyle(
                            fontSize: size * 0.13,
                            fontWeight: FontWeight.w700,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                  if (label != null)
                    Text(
                      label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: tokens.textMuted,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Attendance-specific alias kept for call-site readability.
class AttendanceDonut extends PercentDonut {
  const AttendanceDonut({
    super.key,
    required super.percent,
    super.size,
    super.strokeWidth,
    super.color,
    super.label,
  });
}

/// Vertical bar distribution (e.g. exam mark buckets). No text is drawn; the
/// caller supplies accessible labels/tooltips if needed.
class DistributionBars extends StatelessWidget {
  const DistributionBars({
    super.key,
    required this.values,
    this.height = 64,
    this.color,
    this.barWidth = 14,
    this.gap = 8,
  });

  final List<double> values;
  final double height;
  final Color? color;
  final double barWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brand;
    if (values.isEmpty) return SizedBox(height: height);
    final maxV = values.reduce(math.max);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final value in values)
            Flexible(
              child: Container(
                width: barWidth,
                height: maxV <= 0
                    ? 4
                    : math.max(4, (value / maxV) * (height - 4)),
                decoration: BoxDecoration(
                  color: value <= 0
                      ? accent.withValues(alpha: 0.12)
                      : accent.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Reduces a long series to at most [maxPoints] values by averaging adjacent
/// buckets. Keeps the trend readable without a jagged, noisy line.
List<double> downsampleSeries(List<double> values, int maxPoints) {
  if (values.length <= maxPoints || maxPoints < 2) return values;
  final result = <double>[];
  for (var i = 0; i < maxPoints; i++) {
    final start = (i * values.length / maxPoints).floor();
    final end = (((i + 1) * values.length) / maxPoints).ceil().clamp(
      start + 1,
      values.length,
    );
    var sum = 0.0;
    for (var j = start; j < end; j++) {
      sum += values[j];
    }
    result.add(sum / (end - start));
  }
  return result;
}

/// Catmull-Rom style cubic path: smooth, rounded segments instead of a
/// polyline. Control points are clamped to [bounds] so the curve never
/// overshoots the chart.
Path smoothPathThrough(
  List<Offset> points, {
  double tension = 0.85,
  Rect? bounds,
}) {
  final path = Path();
  if (points.isEmpty) return path;
  path.moveTo(points.first.dx, points.first.dy);
  if (points.length == 1) return path;
  for (var i = 0; i < points.length - 1; i++) {
    final p0 = i == 0 ? points[0] : points[i - 1];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = i + 2 < points.length ? points[i + 2] : p2;
    var c1 = Offset(
      p1.dx + (p2.dx - p0.dx) / 6 * tension,
      p1.dy + (p2.dy - p0.dy) / 6 * tension,
    );
    var c2 = Offset(
      p2.dx - (p3.dx - p1.dx) / 6 * tension,
      p2.dy - (p3.dy - p1.dy) / 6 * tension,
    );
    if (bounds != null) {
      c1 = Offset(
        c1.dx.clamp(bounds.left, bounds.right),
        c1.dy.clamp(bounds.top, bounds.bottom),
      );
      c2 = Offset(
        c2.dx.clamp(bounds.left, bounds.right),
        c2.dy.clamp(bounds.top, bounds.bottom),
      );
    }
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path;
}

/// Attendance-over-time line chart with a soft fill and a dot on every point.
/// A single point is still drawn (centred) instead of leaving an empty box.
class AttendanceTrendChart extends StatelessWidget {
  const AttendanceTrendChart({
    super.key,
    required this.values,
    this.height = 84,
    this.color,
    this.maxPoints = 8,
  });

  final List<double> values;
  final double height;
  final Color? color;
  final int maxPoints;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brand;
    final points = downsampleSeries(values, maxPoints);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          values: points,
          color: accent,
          gridColor: tokens.borderStructural,
          emptyColor: tokens.textMuted.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (value <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value.clamp(0, 1), false, arc);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.values,
    required this.color,
    required this.gridColor,
    required this.emptyColor,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTWH(2, 4, size.width - 4, size.height - 8);

    // Two faint horizontal guides keep the chart readable without noise.
    final grid = Paint()
      ..color = gridColor.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = chart.top + chart.height * (i / 2);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }

    if (values.isEmpty) {
      final placeholder = Paint()
        ..color = emptyColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(chart.left, chart.center.dy),
        Offset(chart.right, chart.center.dy),
        placeholder,
      );
      return;
    }

    double minV = values.reduce(math.min);
    double maxV = values.reduce(math.max);
    if (maxV == minV) {
      // A flat series should read as a centred line, not divide by zero.
      minV -= 1;
      maxV += 1;
    }
    final span = maxV - minV;

    Offset pointAt(int i) {
      final y = chart.bottom - ((values[i] - minV) / span) * chart.height;
      if (values.length == 1) {
        return Offset(chart.center.dx, y.clamp(chart.top, chart.bottom));
      }
      final x = chart.left + chart.width * (i / (values.length - 1));
      return Offset(x, y.clamp(chart.top, chart.bottom));
    }

    final points = [for (var i = 0; i < values.length; i++) pointAt(i)];
    final line = smoothPathThrough(points, bounds: chart);

    final fill = Path.from(line)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.01),
          ],
        ).createShader(chart),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );

    final dot = Paint()..color = color;
    final halo = Paint()..color = color.withValues(alpha: 0.18);
    // Downsampled series are short; keep dots subtle and only halo the last
    // point so the curve stays the hero.
    for (var i = 0; i < points.length; i++) {
      if (i == points.length - 1) canvas.drawCircle(points[i], 4.2, halo);
      canvas.drawCircle(points[i], 2.0, dot);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.values != values ||
      old.color != color ||
      old.gridColor != gridColor ||
      old.emptyColor != emptyColor;
}
