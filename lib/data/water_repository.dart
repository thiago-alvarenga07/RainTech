import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/water_snapshot.dart';

class WaterRepository {
  WaterRepository({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  final SupabaseClient? _client;

  bool get isConnected => _client != null;

  Future<WaterSnapshot> loadSnapshot() async {
    final client = _client;
    if (client == null) return _demoSnapshot();

    final reservoirRows = await client
        .from('reservoir_levels')
        .select()
        .order('Date', ascending: false)
        .limit(1);
    final rainfallRows = await client
        .from('rainfall')
        .select()
        .order('Date', ascending: false)
        .limit(30);

    if (reservoirRows.isEmpty) {
      throw StateError('A tabela reservoir_levels ainda não tem registros.');
    }
    if (rainfallRows.isEmpty) {
      throw StateError('A tabela rainfall ainda não tem registros.');
    }

    final latest = reservoirRows.first;
    final reservoirs = [
      _reservoir(latest, 'São Paulo', 'POONDI', 3231),
      _reservoir(latest, 'Rio de Janeiro', 'CHOLAVARAM', 881),
      _reservoir(latest, 'Fortaleza', 'REDHILLS', 3300),
      _reservoir(latest, 'Salvador', 'CHEMBARAMBAKKAM', 3645),
    ];
    final rainfall = rainfallRows.map((row) {
      return RainObservation(
        date: DateTime.parse(row['Date'].toString()),
        poondiMm: _number(row['POONDI'], 'POONDI'),
        cholavaramMm: _number(row['CHOLAVARAM'], 'CHOLAVARAM'),
        redhillsMm: _number(row['REDHILLS'], 'REDHILLS'),
        chembarambakkamMm: _number(row['CHEMBARAMBAKKAM'], 'CHEMBARAMBAKKAM'),
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    return WaterSnapshot(
      observedAt: DateTime.parse(latest['Date'].toString()),
      reservoirs: reservoirs,
      rainfall: rainfall,
    );
  }

  Reservoir _reservoir(
    Map<String, dynamic> row,
    String name,
    String column,
    double capacityMcft,
  ) {
    return Reservoir(
      name: name,
      storageMcft: _number(row[column], column),
      capacityMcft: capacityMcft,
    );
  }

  double _number(dynamic value, String column) {
    final parsed = double.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException('Valor inválido na coluna "$column".');
    }
    return parsed;
  }

  WaterSnapshot _demoSnapshot() {
    final today = DateTime.now();
    final rainfallAmounts = [0.0, 1.8, 0.0, 4.2, 2.5, 0.7, 0.0, 3.1, 0.0, 1.2];
    final rainfall = List.generate(rainfallAmounts.length, (index) {
      final daysAgo = rainfallAmounts.length - index - 1;
      final rainfall = rainfallAmounts[index];
      return RainObservation(
        date: DateTime(today.year, today.month, today.day - daysAgo),
        poondiMm: rainfall,
        cholavaramMm: rainfall * 0.8,
        redhillsMm: rainfall * 1.1,
        chembarambakkamMm: rainfall * 0.9,
      );
    });

    return WaterSnapshot(
      observedAt: DateTime(today.year, today.month, today.day),
      reservoirs: const [
        Reservoir(name: 'São Paulo', storageMcft: 1370, capacityMcft: 3231),
        Reservoir(name: 'Rio de Janeiro', storageMcft: 390, capacityMcft: 881),
        Reservoir(name: 'Fortaleza', storageMcft: 1750, capacityMcft: 3300),
        Reservoir(name: 'Salvador', storageMcft: 1690, capacityMcft: 3645),
      ],
      rainfall: rainfall,
    );
  }
}
