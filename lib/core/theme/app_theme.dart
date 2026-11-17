import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Fábrica dos temas do app (claro, escuro e alto contraste).
abstract final class AppTheme {
  static ThemeData light({bool highContrast = false}) =>
      _build(Brightness.light, highContrast);

  static ThemeData dark({bool highContrast = false}) =>
      _build(Brightness.dark, highContrast);

  static ThemeData _build(Brightness brightness, bool highContrast) {
    final isDark = brightness == Brightness.dark;

    var scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
      contrastLevel: highContrast ? 1.0 : 0.0,
    );
    if (highContrast) {
      scheme = scheme.copyWith(
        surface: isDark ? Colors.black : Colors.white,
        onSurface: isDark ? Colors.white : Colors.black,
        onSurfaceVariant: isDark ? Colors.white : Colors.black,
        outline: isDark ? Colors.white : Colors.black,
      );
    }

    final base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      useMaterial3: true,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      side: highContrast
          ? BorderSide(color: scheme.outline, width: 1.5)
          : BorderSide.none,
    );

    return base.copyWith(
      scaffoldBackgroundColor: highContrast
          ? scheme.surface
          : (isDark ? null : AppColors.lightBackground),
      cardTheme: CardThemeData(
        shape: shape,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: highContrast
            ? scheme.surface
            : (isDark ? null : AppColors.lightBackground),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        filled: true,
      ),
    );
  }

  
  static Color riskColor(BuildContext context, RiskLevel level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (level) {
      RiskLevel.high => isDark ? AppColors.riskHighDark : AppColors.riskHigh,
      RiskLevel.medium =>
        isDark ? AppColors.riskMediumDark : AppColors.riskMedium,
      RiskLevel.low => isDark ? AppColors.riskLowDark : AppColors.riskLow,
    };
  }
}

enum RiskLevel { low, medium, high }