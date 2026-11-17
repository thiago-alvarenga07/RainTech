import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/water_snapshot.dart';

import '../models/alert.dart';

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
  static const _highContrastKey = 'prefs.highContrast';
  static const _fontScaleKey = 'prefs.fontScale';
  static const _alertReviewsKey = 'alerts.reviews';
  static const _reviewStorageConsentKey = 'privacy.reviewStorageConsent';

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

  bool get highContrast => _prefs.getBool(_highContrastKey) ?? false;

  Future<void> setHighContrast(bool value) =>
      _prefs.setBool(_highContrastKey, value);

  double get fontScale => _prefs.getDouble(_fontScaleKey) ?? 1.0;

  Future<void> setFontScale(double value) =>
      _prefs.setDouble(_fontScaleKey, value);

  bool get reviewStorageConsent =>
      _prefs.getBool(_reviewStorageConsentKey) ?? false;

  Future<void> setReviewStorageConsent(bool value) =>
      _prefs.setBool(_reviewStorageConsentKey, value);

  // ---------- Decisões humanas sobre alertas ----------

  Map<String, AlertReview> loadAlertReviews() {
    final raw = _prefs.getString(_alertReviewsKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (id, value) =>
            MapEntry(id, AlertReview.fromJson(value as Map<String, dynamic>)),
      );
    } on Object {
      return {};
    }
  }

  Future<void> saveAlertReviews(Map<String, AlertReview> reviews) =>
      _prefs.setString(
        _alertReviewsKey,
        jsonEncode(reviews.map((id, review) => MapEntry(id, review.toJson()))),
      );

  Future<void> clearAlertReviews() => _prefs.remove(_alertReviewsKey);
}