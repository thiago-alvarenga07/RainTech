import 'package:flutter/foundation.dart';

import '../data/app_storage.dart';
import '../data/water_repository.dart';
import '../models/water_snapshot.dart';

enum LoadStatus { loading, success, empty, error }

/// Fluxo: busca na fonte (Supabase ou demonstração) → salva no cache.
/// Se a busca falhar, usa o último cache salvo e avisa a interface.
class WaterDataState extends ChangeNotifier {
  WaterDataState(this._repository, this._storage);

  final WaterRepository _repository;
  final AppStorage _storage;

  LoadStatus _status = LoadStatus.loading;
  WaterSnapshot? _snapshot;
  String? _errorMessage;
  bool _isFromCache = false;

  LoadStatus get status => _status;
  WaterSnapshot? get snapshot => _snapshot;
  String? get errorMessage => _errorMessage;

  bool get isFromCache => _isFromCache;


  DateTime? get cacheSavedAt => _storage.snapshotSavedAt;

  bool get isDemo => !_repository.isConnected;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _repository.loadSnapshot();
      _snapshot = snapshot;
      _isFromCache = false;
      _status = snapshot.isEmpty ? LoadStatus.empty : LoadStatus.success;
      if (!snapshot.isEmpty) await _storage.saveSnapshot(snapshot);
    } on Object catch (error) {
      final cached = _storage.loadSnapshot();
      if (cached != null && !cached.isEmpty) {
        _snapshot = cached;
        _isFromCache = true;
        _status = LoadStatus.success;
      } else {
        _snapshot = null;
        _status = LoadStatus.error;
        _errorMessage = _friendlyMessage(error);
      }
    }
    notifyListeners();
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Failed host lookup')) {
      return 'Sem conexão com a internet e nenhum dado salvo no aparelho.';
    }
    return text;
  }
}