import 'package:flutter/foundation.dart';

import '../analytics/alert_engine.dart';
import '../data/app_storage.dart';
import '../models/alert.dart';
import '../models/water_snapshot.dart';
import 'water_data_state.dart';

class AlertsState extends ChangeNotifier {
  AlertsState(this._storage) : _reviews = _storage.loadAlertReviews();

  final AppStorage _storage;
  final Map<String, AlertReview> _reviews;
  final AlertEngine _engine = const AlertEngine();

  List<PredictiveAlert> _alerts = const [];
  WaterSnapshot? _lastSnapshot;
  bool _lastFromCache = false;

  List<PredictiveAlert> get alerts => _alerts;


  List<PredictiveAlert> get pending =>
      _alerts.where((a) => !_reviews.containsKey(a.id)).toList();

  PredictiveAlert? byId(String id) =>
      _alerts.where((a) => a.id == id).firstOrNull;

  List<PredictiveAlert> forCity(String city) =>
      _alerts.where((a) => a.city == city).toList();

  AlertReview? reviewOf(String id) => _reviews[id];

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
    await _storage.saveAlertReviews(_reviews);
  }

  Future<void> undoReview(String alertId) async {
    _reviews.remove(alertId);
    notifyListeners();
    await _storage.saveAlertReviews(_reviews);
  }
}