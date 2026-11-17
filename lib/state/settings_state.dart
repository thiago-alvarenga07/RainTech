import 'package:flutter/material.dart';

import '../data/app_storage.dart';

/// Preferências de aparência e acessibilidade, persistidas localmente.
class SettingsState extends ChangeNotifier {
  SettingsState(this._storage) {
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == _storage.themeMode,
      orElse: () => ThemeMode.light,
    );
    _highContrast = _storage.highContrast;
    _fontScale = _storage.fontScale.clamp(minFontScale, maxFontScale);
  }

  static const minFontScale = 0.85;
  static const maxFontScale = 1.5;

  final AppStorage _storage;
  late ThemeMode _themeMode;
  late bool _highContrast;
  late double _fontScale;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get highContrast => _highContrast;
  double get fontScale => _fontScale;

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _storage.setThemeMode(_themeMode.name);
  }

  Future<void> setHighContrast(bool enabled) async {
    _highContrast = enabled;
    notifyListeners();
    await _storage.setHighContrast(enabled);
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(minFontScale, maxFontScale);
    notifyListeners();
    await _storage.setFontScale(_fontScale);
  }
}