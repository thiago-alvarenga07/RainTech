import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/water_snapshot.dart';

/// Persistência local (SharedPreferences): cache dos dados e preferências.
/// Permite que o app continue útil sem conexão.
class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppStorage> create() async =>
      AppStorage(await SharedPreferences.getInstance());

  static const _snapshotKey = 'cache.snapshot';
  static const _snapshotSavedAtKey = 'cache.snapshot.savedAt';
  static const _themeModeKey = 'prefs.themeMode';

  Future<void> saveSnapshot(WaterSnapshot snapshot) async {
    await _prefs.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
    await _prefs.setString(
      _snapshotSavedAtKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Retorna o último snapshot salvo, ou `null` se não houver cache válido.
  WaterSnapshot? loadSnapshot() {
    final raw = _prefs.getString(_snapshotKey);
    if (raw == null) return null;
    try {
      return WaterSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null; // cache corrompido ou de versão antiga
    }
  }

  DateTime? get snapshotSavedAt {
    final raw = _prefs.getString(_snapshotSavedAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  String? get themeMode => _prefs.getString(_themeModeKey);

  Future<void> setThemeMode(String value) =>
      _prefs.setString(_themeModeKey, value);
}