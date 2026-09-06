import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens exposed as a [ThemeExtension]: radii, shadows, and the
/// semantic palette used across the app.
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.brand,
    required this.brandDark,
    required this.brandLight,
    required this.gold,
    required this.sky,
    required this.coral,
    required this.violet,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.shadowSoft,
  });

  final Color brand;
  final Color brandDark;
  final Color brandLight;
  final Color gold;
  final Color sky;
  final Color coral;
  final Color violet;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final List<BoxShadow> shadowSoft;

  static const AppTokens dark = AppTokens(
    brand: AppColors.emerald,
    brandDark: AppColors.emeraldDark,
    brandLight: AppColors.emeraldLight,
    gold: AppColors.gold,
    sky: AppColors.sky,
    coral: AppColors.coral,
    violet: AppColors.violet,
    radiusSmall: 12,
    radiusMedium: 16,
    radiusLarge: 24,
    shadowSoft: [
      BoxShadow(
        color: Color(0x220F172A),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const AppTokens light = AppTokens(
    brand: AppColors.emeraldDark,
    brandDark: AppColors.emerald,
    brandLight: AppColors.emeraldLight,
    gold: AppColors.gold,
    sky: AppColors.sky,
    coral: AppColors.coral,
    violet: AppColors.violet,
    radiusSmall: 12,
    radiusMedium: 16,
    radiusLarge: 24,
    shadowSoft: [
      BoxShadow(
        color: Color(0x140F172A),
        blurRadius: 12,
        offset: Offset(0, 3),
      ),
    ],
  );

  @override
  AppTokens copyWith({
    Color? brand,
    Color? brandDark,
    Color? brandLight,
    Color? gold,
    Color? sky,
    Color? coral,
    Color? violet,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    List<BoxShadow>? shadowSoft,
  }) {
    return AppTokens(
      brand: brand ?? this.brand,
      brandDark: brandDark ?? this.brandDark,
      brandLight: brandLight ?? this.brandLight,
      gold: gold ?? this.gold,
      sky: sky ?? this.sky,
      coral: coral ?? this.coral,
      violet: violet ?? this.violet,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      shadowSoft: shadowSoft ?? this.shadowSoft,
    );
  }

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      brand: Color.lerp(brand, other.brand, t)!,
      brandDark: Color.lerp(brandDark, other.brandDark, t)!,
      brandLight: Color.lerp(brandLight, other.brandLight, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t)!,
      radiusMedium: lerpDouble(radiusMedium, other.radiusMedium, t)!,
      radiusLarge: lerpDouble(radiusLarge, other.radiusLarge, t)!,
      shadowSoft: t < 0.5 ? shadowSoft : other.shadowSoft,
    );
  }
}

/// Centralised theme factory. Dark is the default.
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(Brightness.dark, AppTokens.dark);

  static ThemeData light() => _build(Brightness.light, AppTokens.light);

  static ThemeData _build(Brightness brightness, AppTokens tokens) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.brand,
      brightness: brightness,
    );
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
    );
    return base.copyWith(
      extensions: [tokens],
      scaffoldBackgroundColor: isDark ? AppColors.ink : AppColors.paper,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? AppColors.ink : AppColors.paper,
        foregroundColor: isDark ? AppColors.paper : AppColors.ink,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMedium),
        ),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : AppColors.fog,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
        ),
      ),
    );
  }
}