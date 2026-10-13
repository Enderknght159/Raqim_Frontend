import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Raqim brand logo (square mark).
///
/// Automatically picks the correct variant for the current theme:
/// - `Raqim_Logo_DTBG.svg` (bright sky/emerald/gold) on **dark** backgrounds
/// - `Raqim_Logo_LTBG.svg` (deep teal/green) on **light** backgrounds
class RaqimLogo extends StatelessWidget {
  const RaqimLogo({
    super.key,
    this.size = 120,
    this.brightness,
  });

  final double size;

  /// Explicit brightness override; defaults to [Theme.of(context).brightness].
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness =
        brightness ?? Theme.of(context).brightness;
    final asset = effectiveBrightness == Brightness.dark
        ? 'assets/logo/Raqim_Logo_DTBG.svg'
        : 'assets/logo/Raqim_Logo_LTBG.svg';
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      semanticsLabel: 'رقيم',
    );
  }
}