import 'package:flutter/material.dart';

/// Palette tokens: emerald / gold / sky / coral / violet (dark default).
class AppColors {
  AppColors._();

  // Brand primary — emerald
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF34D399);

  // Gold — rewards, points
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldDark = Color(0xFFB45309);

  // Sky — information, scans
  static const Color sky = Color(0xFF0EA5E9);
  static const Color skyDark = Color(0xFF0369A1);

  // Coral — alerts, late
  static const Color coral = Color(0xFFF43F5E);
  static const Color coralDark = Color(0xFFBE123C);

  // Violet — admin, extras
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDark = Color(0xFF6D28D9);

  // Neutrals
  static const Color ink = Color(0xFF0F172A);
  static const Color slate = Color(0xFF334155);
  static const Color mist = Color(0xFF94A3B8);
  static const Color fog = Color(0xFFE2E8F0);
  static const Color paper = Color(0xFFF8FAFC);

  // Semantic
  static const Color success = emerald;
  static const Color warning = gold;
  static const Color danger = coral;
  static const Color info = sky;
}