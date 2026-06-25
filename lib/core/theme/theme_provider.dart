import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ключ для збереження теми у SharedPreferences
const _kThemeModeKey = 'theme_mode';

/// Конвертація ThemeMode → рядок для збереження
String _themeModeToString(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'light',
  ThemeMode.dark => 'dark',
  ThemeMode.system => 'system',
};

/// Відновлення ThemeMode із збереженого рядка
ThemeMode _themeModeFromString(String? value) => switch (value) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  'system' => ThemeMode.system,
  // За замовчуванням — світла тема (домовленість дизайну)
  _ => ThemeMode.light,
};

/// Провайдер SharedPreferences — ініціалізується до запуску MaterialApp.
/// Передається через ProviderScope.overrides у main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences не ініціалізовано'),
);

/// Нотифікатор теми: зберігає ThemeMode і персистить вибір у SharedPreferences
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Відновлюємо збережений вибір при старті
    final prefs = ref.read(sharedPreferencesProvider);
    return _themeModeFromString(prefs.getString(_kThemeModeKey));
  }

  /// Встановити тему і зберегти в SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kThemeModeKey, _themeModeToString(mode));
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
