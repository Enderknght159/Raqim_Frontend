import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Emotional states for the flat "student character" art.
/// See `ui-ux-foundations.md` §9 — no images are produced yet; this is a
/// unified placeholder describing the character (state + icon + prompt).
enum CharacterState {
  welcome(Icons.waving_hand, 'cute mosque kid waving, flat vector, brand green, plain white bg'),
  busy(Icons.auto_stories, 'kid focused reading Quran, warm, flat vector'),
  proud(Icons.menu_book, 'kid proudly holding a glowing Quran page'),
  celebrating(Icons.celebration, 'kid jumping, confetti, stars, joyful'),
  surprised(Icons.emoji_emotions, 'surprised kid, wide eyes, flat vector'),
  encouraging(Icons.rocket_launch, 'kid at a start path, hopeful'),
  crowned(Icons.emoji_events, 'kid wearing a medal, very proud'),
  waiting(Icons.hourglass_top, 'friendly kid waiting patiently, hourglass, flat vector');

  const CharacterState(this.icon, this.prompt);

  final IconData icon;
  final String prompt;
}

/// Placeholder for the student character art (to be replaced by real assets).
///
/// Renders a dashed frame + a Material icon + (dev only) the generation prompt.
class CharacterArt extends StatelessWidget {
  const CharacterArt({
    super.key,
    this.state = CharacterState.welcome,
    this.size = 140,
    this.color,
  });

  final CharacterState state;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = color ?? tokens.brand;
    return CustomPaint(
      painter: _DashedBorderPainter(color: accent.withValues(alpha: 0.5)),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(state.icon, size: size * 0.34, color: accent),
            if (kDebugMode) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  state.prompt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: tokens.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 5.0;
    const r = 12.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(r),
      ));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
