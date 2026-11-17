import 'package:flutter/foundation.dart';

import '../analytics/alert_engine.dart';
import '../data/app_storage.dart';
import '../models/alert.dart';
import '../models/water_snapshot.dart';
import 'water_data_state.dart';

class AlertsState extends ChangeNotifier {
  AlertsState(this._storage)
    : _canPersistReviews = _storage.reviewStorageConsent,
      _reviews = _storage.reviewStorageConsent
          ? _storage.loadAlertReviews()
          : {};

  final AppStorage _storage;
  final Map<String, AlertReview> _reviews;
  bool _canPersistReviews;
  final AlertEngine _engine = const AlertEngine();

  List<PredictiveAlert> _alerts = const [];
  WaterSnapshot? _lastSnapshot;
  bool _lastFromCache = false;

  List<PredictiveAlert> get alerts => _alerts;
  bool get canPersistReviews => _canPersistReviews;


  List<PredictiveAlert> get pending =>
      _alerts.where((a) => !_reviews.containsKey(a.id)).toList();

  PredictiveAlert? byId(String id) =>
      _alerts.where((a) => a.id == id).firstOrNull;

  List<PredictiveAlert> forCity(String city) =>
      _alerts.where((a) => a.city == city).toList();

  AlertReview? reviewOf(String id) => _reviews[id];

  Future<void> setReviewStorageConsent(bool enabled) async {
    if (enabled == _canPersistReviews) return;

    if (enabled) {
      await _storage.setReviewStorageConsent(true);
      _canPersistReviews = true;
      notifyListeners();
      await _storage.saveAlertReviews(_reviews);
      return;
    }

    await _storage.clearAlertReviews();
    await _storage.setReviewStorageConsent(false);
    _canPersistReviews = false;
    _reviews.clear();
    notifyListeners();
  }

  /// Chamado pelo ProxyProvider sempre que [WaterDataState] notifica.
  void updateFrom(WaterDataState data) {
    final snapshot = data.snapshot;
    if (identical(snapshot, _lastSnapshot) &&
        data.isFromCache == _lastFromCache) {
      return;
    }
    _lastSnapshot = snapshot;
    _lastFromCache = data.isFromCache;
    _recalculate(isDemo: data.isDemo);
  }

  void _recalculate({required bool isDemo}) {
    final snapshot = _lastSnapshot;
    _alerts = snapshot == null
        ? const []
        : _engine.evaluate(
            snapshot,
            isDemo: isDemo,
            isFromCache: _lastFromCache,
          );
    notifyListeners();
  }

  Future<void> review(
    String alertId,
    AlertDecision decision,
    String note,
  ) async {
    _reviews[alertId] = AlertReview(
      decision: decision,
      note: note.trim(),
      reviewedAt: DateTime.now(),
    );
    notifyListeners();
    if (_canPersistReviews) {
      await _storage.saveAlertReviews(_reviews);
    }
  }

  Future<void> undoReview(String alertId) async {
    _reviews.remove(alertId);
    notifyListeners();
    if (_canPersistReviews) {
      await _storage.saveAlertReviews(_reviews);
    }
  }
}