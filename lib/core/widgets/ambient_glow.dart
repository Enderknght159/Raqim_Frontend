import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Decorative blurred color blob tucked behind card corners (stitch draft:
/// `bg-primary/10 rounded-full blur-3xl`).
class AmbientGlow extends StatelessWidget {
  const AmbientGlow({
    super.key,
    required this.color,
    this.size = 160,
    this.alignment = Alignment.topLeft,
    this.opacity = 0.12,
  });

  final Color color;
  final double size;
  final Alignment alignment;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
