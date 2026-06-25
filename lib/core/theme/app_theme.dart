import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Теми застосунку "Свої".
/// Типографіка побудована у стилі мінімалістичних fintech-додатків (Monobank/Дія):
/// чіткі заголовки, читабельний body, акуратні підписи.
abstract final class AppTheme {
  // ── Типографіка (спільна для обох тем) ───────────────────────────────────

  static TextTheme _buildTextTheme(ColorScheme scheme) {
    // Inter як основний шрифт
    final base = GoogleFonts.interTextTheme();

    return base.copyWith(
      // Великі заголовки — секції, модалки
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),

      // Заголовки екранів і карток
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: scheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),

      // Основний текст — оголошення, описи
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: scheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: scheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),

      // Підписи, теги, мітки
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: scheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  // ── Спільні параметри компонентів ─────────────────────────────────────────

  static AppBarTheme _buildAppBarTheme(ColorScheme scheme) {
    return AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme(
    ColorScheme scheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: scheme.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurfaceVariant,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    );
  }

  static TabBarThemeData _buildTabBarTheme(ColorScheme scheme) {
    return TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: scheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      dividerColor: scheme.outlineVariant,
    );
  }

  static CardThemeData _buildCardTheme(ColorScheme scheme) {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant, width: 1),
      ),
      color: scheme.surfaceContainerLowest,
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 52),
      ),
    );
  }

  // ── Світла тема ───────────────────────────────────────────────────────────

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _buildTextTheme(scheme),
      appBarTheme: _buildAppBarTheme(scheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(scheme),
      tabBarTheme: _buildTabBarTheme(scheme),
      cardTheme: _buildCardTheme(scheme),
      filledButtonTheme: _buildFilledButtonTheme(scheme),
      scaffoldBackgroundColor: scheme.surface,
    );
  }

  // ── Темна тема ────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _buildTextTheme(scheme),
      appBarTheme: _buildAppBarTheme(scheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(scheme),
      tabBarTheme: _buildTabBarTheme(scheme),
      cardTheme: _buildCardTheme(scheme),
      filledButtonTheme: _buildFilledButtonTheme(scheme),
      scaffoldBackgroundColor: scheme.surface,
    );
  }
}
