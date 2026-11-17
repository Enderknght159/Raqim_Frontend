import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'metric_charts.dart';

/// Minimal sparkline (cumulative points trend) with a soft filled area.
/// The series is downsampled and drawn as a smooth curve so a busy log does
/// not turn into a jagged zig-zag.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color,
    this.height = 56,
  });

  final List<double> values;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.reward;
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: downsampleSeries(values, 8),
          color: accent,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final chart = Rect.fromLTWH(2, 4, size.width - 4, size.height - 8);
    if (values.length == 1) {
      canvas.drawCircle(
        chart.center,
        2.5,
        Paint()..color = color,
      );
      return;
    }
    double minV = values.reduce((a, b) => a < b ? a : b);
    double maxV = values.reduce((a, b) => a > b ? a : b);
    final span = maxV - minV;
    if (span == 0) {
      canvas.drawLine(
        Offset(chart.left, chart.center.dy),
        Offset(chart.right, chart.center.dy),
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    Offset pointAt(int i) {
      final x = chart.left + chart.width * (i / (values.length - 1));
      final y = chart.bottom - ((values[i] - minV) / span) * chart.height;
      return Offset(x, y.clamp(chart.top, chart.bottom));
    }

    final points = [for (var i = 0; i < values.length; i++) pointAt(i)];
    final linePath = smoothPathThrough(points, bounds: chart);

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(chart),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}
