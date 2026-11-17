class Reservoir {
  const Reservoir({
    required this.name,
    required this.storageMcft,
    required this.capacityMcft,
  });

  final String name;
  final double storageMcft;
  final double capacityMcft;

  double get fillRatio => capacityMcft <= 0
      ? 0
      : (storageMcft / capacityMcft).clamp(0.0, 1.0).toDouble();

  Map<String, dynamic> toJson() => {
    'name': name,
    'storageMcft': storageMcft,
    'capacityMcft': capacityMcft,
  };

  factory Reservoir.fromJson(Map<String, dynamic> json) => Reservoir(
    name: json['name'] as String,
    storageMcft: (json['storageMcft'] as num).toDouble(),
    capacityMcft: (json['capacityMcft'] as num).toDouble(),
  );
}

class ReservoirReading {
  const ReservoirReading({required this.date, required this.storageByCity});

  final DateTime date;
  final Map<String, double> storageByCity;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'storageByCity': storageByCity,
  };

  factory ReservoirReading.fromJson(Map<String, dynamic> json) =>
      ReservoirReading(
        date: DateTime.parse(json['date'] as String),
        storageByCity: (json['storageByCity'] as Map<String, dynamic>).map(
          (city, value) => MapEntry(city, (value as num).toDouble()),
        ),
      );
}

class RainObservation {
  const RainObservation({
    required this.date,
    required this.poondiMm,
    required this.cholavaramMm,
    required this.redhillsMm,
    required this.chembarambakkamMm,
  });

  final DateTime date;
  final double poondiMm;
  final double cholavaramMm;
  final double redhillsMm;
  final double chembarambakkamMm;

  double get regionalAverageMm =>
      (poondiMm + cholavaramMm + redhillsMm + chembarambakkamMm) / 4;

  List<RainGaugeReading> get gaugeReadings => [
    RainGaugeReading(name: 'São Paulo', rainfallMm: poondiMm),
    RainGaugeReading(name: 'Rio de Janeiro', rainfallMm: cholavaramMm),
    RainGaugeReading(name: 'Fortaleza', rainfallMm: redhillsMm),
    RainGaugeReading(name: 'Salvador', rainfallMm: chembarambakkamMm),
  ];

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'poondiMm': poondiMm,
    'cholavaramMm': cholavaramMm,
    'redhillsMm': redhillsMm,
    'chembarambakkamMm': chembarambakkamMm,
  };

  factory RainObservation.fromJson(Map<String, dynamic> json) =>
      RainObservation(
        date: DateTime.parse(json['date'] as String),
        poondiMm: (json['poondiMm'] as num).toDouble(),
        cholavaramMm: (json['cholavaramMm'] as num).toDouble(),
        redhillsMm: (json['redhillsMm'] as num).toDouble(),
        chembarambakkamMm: (json['chembarambakkamMm'] as num).toDouble(),
      );
}

class RainGaugeReading {
  const RainGaugeReading({required this.name, required this.rainfallMm});

  final String name;
  final double rainfallMm;
}

class WaterSnapshot {
  const WaterSnapshot({
    required this.observedAt,
    required this.reservoirs,
    required this.rainfall,
    this.reservoirHistory = const [],
  });

  final DateTime observedAt;
  final List<Reservoir> reservoirs;

  final List<RainObservation> rainfall;

  final List<ReservoirReading> reservoirHistory;

  bool get isEmpty => reservoirs.isEmpty || rainfall.isEmpty;

  Map<String, dynamic> toJson() => {
    'observedAt': observedAt.toIso8601String(),
    'reservoirs': reservoirs.map((r) => r.toJson()).toList(),
    'rainfall': rainfall.map((r) => r.toJson()).toList(),
    'reservoirHistory': reservoirHistory.map((r) => r.toJson()).toList(),
  };

  factory WaterSnapshot.fromJson(Map<String, dynamic> json) => WaterSnapshot(
    observedAt: DateTime.parse(json['observedAt'] as String),
    reservoirs: (json['reservoirs'] as List)
        .map((r) => Reservoir.fromJson(r as Map<String, dynamic>))
        .toList(),
    rainfall: (json['rainfall'] as List)
        .map((r) => RainObservation.fromJson(r as Map<String, dynamic>))
        .toList(),
    reservoirHistory: ((json['reservoirHistory'] as List?) ?? const [])
        .map((r) => ReservoirReading.fromJson(r as Map<String, dynamic>))
        .toList(),
  );

  double get totalStorageMcft =>
      reservoirs.fold(0.0, (total, reservoir) => total + reservoir.storageMcft);

  double get totalCapacityMcft => reservoirs.fold(
    0.0,
    (total, reservoir) => total + reservoir.capacityMcft,
  );

  double get reserveRatio =>
      totalCapacityMcft <= 0 ? 0 : totalStorageMcft / totalCapacityMcft;

  double get recentRainfallAverage {
    final recent = rainfall.length > 7
        ? rainfall.sublist(rainfall.length - 7)
        : rainfall;
    if (recent.isEmpty) return 0;
    return recent.fold<double>(
          0,
          (total, observation) => total + observation.regionalAverageMm,
        ) /
        recent.length;
  }

  List<(DateTime, double)> get reserveRatioHistory {
    if (totalCapacityMcft <= 0) return const [];
    return reservoirHistory.map((reading) {
      final stored = reading.storageByCity.values.fold<double>(
        0,
        (total, value) => total + value,
      );
      return (reading.date, stored / totalCapacityMcft);
    }).toList();
  }

  List<(DateTime, double)> fillHistoryFor(String city) {
    final capacity = reservoirs
        .where((r) => r.name == city)
        .map((r) => r.capacityMcft)
        .firstOrNull;
    if (capacity == null || capacity <= 0) return const [];
    return reservoirHistory
        .where((reading) => reading.storageByCity.containsKey(city))
        .map((reading) => (reading.date, reading.storageByCity[city]! / capacity))
        .toList();
  }
  
  List<(DateTime, double)> rainHistoryFor(String city) => rainfall.map((o) {
    final reading = o.gaugeReadings.where((r) => r.name == city).firstOrNull;
    return (o.date, reading?.rainfallMm ?? 0);
  }).toList();
}