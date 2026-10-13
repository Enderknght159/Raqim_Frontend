import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens exposed as a [ThemeExtension]: the semantic palette, radii
/// and the flat style (no shadows). Light mode only (`ui-palette.md`)).
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.brand,
    required this.brandPressed,
    required this.brandBorder,
    required this.brandTint,
    required this.brandText,
    required this.info,
    required this.infoLight,
    required this.infoTint,
    required this.reward,
    required this.rewardText,
    required this.danger,
    required this.dangerText,
    required this.accentMatn,
    required this.accentMatnText,
    required this.surfacePage,
    required this.surfaceCard,
    required this.surfaceSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderStructural,
    required this.borderInteractive,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
  });

  // Brand / Quran / success
  final Color brand;
  final Color brandPressed;
  final Color brandBorder;
  final Color brandTint;
  final Color brandText;

  // Info / headings
  final Color info;
  final Color infoLight;
  final Color infoTint;

  // Reward
  final Color reward;
  final Color rewardText;

  // Danger
  final Color danger;
  final Color dangerText;

  // Accent (matn/tajweed/admin)
  final Color accentMatn;
  final Color accentMatnText;

  // Surfaces
  final Color surfacePage;
  final Color surfaceCard;
  final Color surfaceSubtle;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Borders
  final Color borderStructural;
  final Color borderInteractive;

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;

  static const AppTokens light = AppTokens(
    brand: AppColors.brand,
    brandPressed: AppColors.brandPressed,
    brandBorder: AppColors.brandBorder,
    brandTint: AppColors.brandTint,
    brandText: AppColors.brandText,
    info: AppColors.info,
    infoLight: AppColors.infoLight,
    infoTint: AppColors.infoTint,
    reward: AppColors.reward,
    rewardText: AppColors.rewardText,
    danger: AppColors.danger,
    dangerText: AppColors.dangerText,
    accentMatn: AppColors.accentMatn,
    accentMatnText: AppColors.accentMatnText,
    surfacePage: AppColors.surfacePage,
    surfaceCard: AppColors.surfaceCard,
    surfaceSubtle: AppColors.surfaceSubtle,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    borderStructural: AppColors.borderStructural,
    borderInteractive: AppColors.brandBorder,
    radiusSmall: 12,
    radiusMedium: 12,
    radiusLarge: 12,
  );

  @override
  AppTokens copyWith({
    Color? brand,
    Color? brandPressed,
    Color? brandBorder,
    Color? brandTint,
    Color? brandText,
    Color? info,
    Color? infoLight,
    Color? infoTint,
    Color? reward,
    Color? rewardText,
    Color? danger,
    Color? dangerText,
    Color? accentMatn,
    Color? accentMatnText,
    Color? surfacePage,
    Color? surfaceCard,
    Color? surfaceSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? borderStructural,
    Color? borderInteractive,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
  }) {
    return AppTokens(
      brand: brand ?? this.brand,
      brandPressed: brandPressed ?? this.brandPressed,
      brandBorder: brandBorder ?? this.brandBorder,
      brandTint: brandTint ?? this.brandTint,
      brandText: brandText ?? this.brandText,
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
      infoTint: infoTint ?? this.infoTint,
      reward: reward ?? this.reward,
      rewardText: rewardText ?? this.rewardText,
      danger: danger ?? this.danger,
      dangerText: dangerText ?? this.dangerText,
      accentMatn: accentMatn ?? this.accentMatn,
      accentMatnText: accentMatnText ?? this.accentMatnText,
      surfacePage: surfacePage ?? this.surfacePage,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      borderStructural: borderStructural ?? this.borderStructural,
      borderInteractive: borderInteractive ?? this.borderInteractive,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
    );
  }

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      brand: Color.lerp(brand, other.brand, t)!,
      brandPressed: Color.lerp(brandPressed, other.brandPressed, t)!,
      brandBorder: Color.lerp(brandBorder, other.brandBorder, t)!,
      brandTint: Color.lerp(brandTint, other.brandTint, t)!,
      brandText: Color.lerp(brandText, other.brandText, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      infoTint: Color.lerp(infoTint, other.infoTint, t)!,
      reward: Color.lerp(reward, other.reward, t)!,
      rewardText: Color.lerp(rewardText, other.rewardText, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      accentMatn: Color.lerp(accentMatn, other.accentMatn, t)!,
      accentMatnText: Color.lerp(accentMatnText, other.accentMatnText, t)!,
      surfacePage: Color.lerp(surfacePage, other.surfacePage, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderStructural:
          Color.lerp(borderStructural, other.borderStructural, t)!,
      borderInteractive:
          Color.lerp(borderInteractive, other.borderInteractive, t)!,
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t)!,
      radiusMedium: lerpDouble(radiusMedium, other.radiusMedium, t)!,
      radiusLarge: lerpDouble(radiusLarge, other.radiusLarge, t)!,
    );
  }
}

/// Centralised theme factory. **Light is the only active theme** (dark
/// deferred — see `ui-ux-foundations.md` §2). [dark] is kept as an alias so
/// older call-sites/tests keep compiling.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppTokens.light);

  static ThemeData dark() => light();

  static ThemeData _build(Brightness brightness, AppTokens tokens) {
    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.brand,
      brightness: brightness,
    ).copyWith(
      primary: tokens.brand,
      onPrimary: Colors.white,
      secondary: tokens.info,
      surface: tokens.surfacePage,
      onSurface: tokens.textPrimary,
      error: tokens.danger,
    );

    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Zain',
      scaffoldBackgroundColor: tokens.surfacePage,
    );

    return base.copyWith(
      extensions: [tokens],
      textTheme: _textTheme(base.textTheme, tokens),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: tokens.surfacePage,
        foregroundColor: tokens.textPrimary,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMedium),
        ),
        color: tokens.surfaceCard,
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderStructural,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceSubtle,
        hintStyle: TextStyle(color: tokens.textMuted),
        labelStyle: TextStyle(color: tokens.textSecondary),
        prefixIconColor: tokens.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          borderSide: BorderSide(color: tokens.borderStructural),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          borderSide: BorderSide(color: tokens.brand, width: 2),
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
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: tokens.surfacePage,
        indicatorColor: tokens.brandTint,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  /// Type scale per `ui-ux-foundations.md` §4:
  /// caption 13 · body 15 · heading-sm 19 · heading 32 · display 48–64.
  static TextTheme _textTheme(TextTheme base, AppTokens tokens) {
    return base.copyWith(
      bodySmall: base.bodySmall?.copyWith(fontSize: 13, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 15, height: 1.6),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, height: 1.6),
      labelLarge: base.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
      titleSmall: base.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w800),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.w900),
      displayMedium: base.displayMedium?.copyWith(fontSize: 48, fontWeight: FontWeight.w900),
      displayLarge: base.displayLarge?.copyWith(fontSize: 64, fontWeight: FontWeight.w900),
    );
  }
}
