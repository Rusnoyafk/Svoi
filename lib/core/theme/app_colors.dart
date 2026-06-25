import 'package:flutter/material.dart';

/// Семантичні та брендові кольори застосунку "Свої".
/// ColorScheme генерується динамічно через ColorScheme.fromSeed у app_theme.dart.
abstract final class AppColors {
  // ── Seed / Brand ─────────────────────────────────────────────────────────
  /// Основний акцент — індиго-фіолетовий
  static const Color primary = Color(0xFF6C4DE6);

  // ── Семантичні стани ──────────────────────────────────────────────────────
  /// Позитивний стан: контакт відкритий, успіх
  static const Color success = Color(0xFF2E7D32);

  /// Попередження: запит надіслано, очікує підтвердження
  static const Color warning = Color(0xFFED6C02);

  /// Нейтральний: контакт не відкритий
  static const Color neutral = Color(0xFF9E9E9E);

  /// Нейтральний фон для чіпів / підкладок
  static const Color neutralSurface = Color(0xFFF5F5F5);
  static const Color neutralSurfaceDark = Color(0xFF2C2C2C);

  // ── Промо-градієнт (фіолетовий → зелений) ────────────────────────────────
  /// М'який перехід для промо-карток та банерів
  static const Gradient promoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C4DE6), // primary
      Color(0xFF388E3C), // green 700 — м'якша версія success
    ],
    stops: [0.0, 1.0],
  );

  /// Більш ніжний промо-варіант з прозорістю
  static const Gradient promoGradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8C6FF0), // primary світліший
      Color(0xFF4CAF50), // green 500
    ],
    stops: [0.0, 1.0],
  );
}
