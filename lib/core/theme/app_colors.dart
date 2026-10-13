import 'package:flutter/material.dart';

/// Palette tokens — **light mode only** (dark deferred).
///
/// Source of truth: `plan/4-design-system/ui-palette.md` (Locked).
/// Provided by the product owner: brand `#00A572`, info/heading `#004C69`,
/// reward `#F59E0B`, surfaceSubtle `#F2F2F2`.
class AppColors {
  AppColors._();

  // ── Brand / Quran / success (green) ─────────────────────────────────────
  static const Color brand = Color(0xFF00A572);
  static const Color brandPressed = Color(0xFF007A55);
  static const Color brandText = Color(0xFF007A55);
  static const Color brandBorder = Color(0xFF5FD0A6);
  static const Color brandTint = Color(0xFFE6F6F1);

  // ── Info / headings (deep teal) ─────────────────────────────────────────
  static const Color info = Color(0xFF004C69);
  static const Color infoLight = Color(0xFF2AA5D6);
  static const Color infoTint = Color(0xFFE5F1F6);

  // ── Reward (gold) ───────────────────────────────────────────────────────
  static const Color reward = Color(0xFFF59E0B);
  static const Color rewardText = Color(0xFFB45309);

  // ── Danger / late (coral) ───────────────────────────────────────────────
  static const Color danger = Color(0xFFE11D48);
  static const Color dangerText = Color(0xFFBE123C);

  // ── Accent (violet) — matn / tajweed / admin ────────────────────────────
  static const Color accentMatn = Color(0xFF7C3AED);
  static const Color accentMatnText = Color(0xFF6D28D9);

  // ── Surfaces ────────────────────────────────────────────────────────────
  static const Color surfacePage = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF2F2F2);

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF4B4B4B);
  static const Color textMuted = Color(0xFF777777);

  // ── Borders ─────────────────────────────────────────────────────────────
  static const Color borderStructural = Color(0xFFE5E5E5);

  /// Character-art palette (flat, no gradients) — see `ui-palette.md` §2.
  static const List<Color> characterArt = [
    Color(0xFFFFE700), // yellow
    Color(0xFFF43F5E), // pink
    Color(0xFF7C3AED), // violet
    Color(0xFF1CB0F6), // blue
    Color(0xFF00A572), // green
    Color(0xFF004C69), // navy
  ];

  // ── Backward-compatible aliases (older widgets) ─────────────────────────
  static const Color emerald = brand;
  static const Color emeraldDark = brandPressed;
  static const Color emeraldLight = brandBorder;
  static const Color gold = reward;
  static const Color goldDark = rewardText;
  static const Color sky = infoLight;
  static const Color skyDark = info;
  static const Color coral = danger;
  static const Color coralDark = dangerText;
  static const Color violet = accentMatn;
  static const Color violetDark = accentMatnText;
  static const Color ink = textPrimary;
  static const Color mist = textMuted;
  static const Color fog = surfaceSubtle;
  static const Color paper = surfacePage;
}
