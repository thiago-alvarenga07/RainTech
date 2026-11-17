import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/water_snapshot.dart';

class WaterRepository {
  WaterRepository({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  final SupabaseClient? _client;

  static const historyDays = 30;

  static const _cities = [
    ('São Paulo', 'POONDI', 3231.0),
    ('Rio de Janeiro', 'CHOLAVARAM', 881.0),
    ('Fortaleza', 'REDHILLS', 3300.0),
    ('Salvador', 'CHEMBARAMBAKKAM', 3645.0),
  ];

  bool get isConnected => _client != null;

  Future<WaterSnapshot> loadSnapshot() async {
    final client = _client;
    if (client == null) return _demoSnapshot();

    final reservoirRows = await client
        .from('reservoir_levels')
        .select()
        .order('Date', ascending: false)
        .limit(historyDays);
    final rainfallRows = await client
        .from('rainfall')
        .select()
        .order('Date', ascending: false)
        .limit(historyDays);

    if (reservoirRows.isEmpty || rainfallRows.isEmpty) {
      return WaterSnapshot(
        observedAt: DateTime.now(),
        reservoirs: const [],
        rainfall: const [],
      );
    }

    final latest = reservoirRows.first;
    final reservoirs = [
      for (final (name, column, capacity) in _cities)
        Reservoir(
          name: name,
          storageMcft: _number(latest[column], column),
          capacityMcft: capacity,
        ),
    ];

    final history = reservoirRows.map((row) {
      return ReservoirReading(
        date: DateTime.parse(row['Date'].toString()),
        storageByCity: {
          for (final (name, column, _) in _cities)
            name: _number(row[column], column),
        },
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

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
      reservoirHistory: history,
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime dayAgo(int days) =>
        DateTime(today.year, today.month, today.day - days);

    const rain = [
      0.0, 2.1, 5.4, 6.8, 3.2, 0.4, 0.0, 0.0, 0.0, 1.2, //
      4.6, 7.9, 6.1, 2.3, 0.6, 0.0, 0.0, 0.0, 0.0, 1.8, //
      3.4, 2.2, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.0, //
    ];

    final rainfall = List.generate(historyDays, (i) {
      final mm = rain[i];
      return RainObservation(
        date: dayAgo(historyDays - 1 - i),
        poondiMm: mm,
        cholavaramMm: mm * 0.8,
        redhillsMm: mm * 1.1,
        chembarambakkamMm: mm * 0.9,
      );
    });


    const finalStorage = {
      'São Paulo': 1370.0,
      'Rio de Janeiro': 300.0,
      'Fortaleza': 1750.0,
      'Salvador': 1690.0,
    };
    const dailyDrop = {
      'São Paulo': 9.0,
      'Rio de Janeiro': 4.5,
      'Fortaleza': 7.0,
      'Salvador': 4.0,
    };

    final history = List.generate(historyDays, (i) {
      final daysToEnd = historyDays - 1 - i;
      // Chuva acumulada daqui até o fim repõe parte do volume.
      final rainAfter = rain.sublist(i + 1).fold<double>(0, (a, b) => a + b);
      return ReservoirReading(
        date: dayAgo(daysToEnd),
        storageByCity: {
          for (final city in finalStorage.keys)
            city:
                finalStorage[city]! +
                dailyDrop[city]! * daysToEnd -
                rainAfter * dailyDrop[city]! * 0.15,
        },
      );
    });

    return WaterSnapshot(
      observedAt: today,
      reservoirs: [
        for (final (name, _, capacity) in _cities)
          Reservoir(
            name: name,
            storageMcft: finalStorage[name]!,
            capacityMcft: capacity,
          ),
      ],
      rainfall: rainfall,
      reservoirHistory: history,
    );
  }
}