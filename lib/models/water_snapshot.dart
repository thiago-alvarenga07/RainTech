const brazilianCityDisplayNames = [
  'São Paulo',
  'Rio de Janeiro',
  'Fortaleza',
  'Salvador',
];

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
  });

  final DateTime observedAt;
  final List<Reservoir> reservoirs;
  final List<RainObservation> rainfall;

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

  double get recentSaoPauloRainfallAverage {
    final recent = rainfall.length > 7
        ? rainfall.sublist(rainfall.length - 7)
        : rainfall;
    if (recent.isEmpty) return 0;
    return recent.fold<double>(
          0,
          (total, observation) => total + observation.poondiMm,
        ) /
        recent.length;
  }
}
