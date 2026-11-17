import 'package:flutter/material.dart';

import '../data/app_storage.dart';

/// Preferências do usuário (tema), persistidas localmente.
class SettingsState extends ChangeNotifier {
  SettingsState(this._storage) {
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == _storage.themeMode,
      orElse: () => ThemeMode.light,
    );
  }

  final AppStorage _storage;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _storage.setThemeMode(_themeMode.name);
  }
}