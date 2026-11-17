import '../models/water_snapshot.dart';


abstract final class Indicators {
  static const criticalReserve = 0.25;
  static const attentionReserve = 0.45;

  static const attentionAutonomyDays = 60.0;


  static double? change(List<(DateTime, double)> series, {int days = 7}) {
    if (series.length <= days) return null;
    return series.last.$2 - series[series.length - 1 - days].$2;
  }


  static double slope(List<double> values) {
    final n = values.length;
    if (n < 2) return 0;
    final meanX = (n - 1) / 2;
    final meanY = values.reduce((a, b) => a + b) / n;
    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < n; i++) {
      numerator += (i - meanX) * (values[i] - meanY);
      denominator += (i - meanX) * (i - meanX);
    }
    return denominator == 0 ? 0 : numerator / denominator;
  }

  static double average(Iterable<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  static int dryStreak(List<double> dailyRain, {double limitMm = 1}) {
    var streak = 0;
    for (final mm in dailyRain.reversed) {
      if (mm >= limitMm) break;
      streak++;
    }
    return streak;
  }
}


abstract final class DemandModel {
  static const litersPerMcft = 28316846.6;

  static const litersPerPersonPerDay = 250.0;

  static const servedPopulation = {
    'São Paulo': 1200000,
    'Rio de Janeiro': 350000,
    'Fortaleza': 1000000,
    'Salvador': 1100000,
  };

  static int get totalPopulation =>
      servedPopulation.values.fold(0, (a, b) => a + b);

  static double dailyDemandMcft(String city) =>
      (servedPopulation[city] ?? 0) * litersPerPersonPerDay / litersPerMcft;

  static double dailyDemandMegaliters(String city) =>
      (servedPopulation[city] ?? 0) * litersPerPersonPerDay / 1e6;

  static double autonomyDays(Reservoir reservoir) {
    final demand = dailyDemandMcft(reservoir.name);
    return demand <= 0 ? 0 : reservoir.storageMcft / demand;
  }


  static List<(DateTime, double)> regionalAutonomyHistory(
    WaterSnapshot snapshot,
  ) {
    final totalDemand = servedPopulation.keys.fold<double>(
      0,
      (total, city) => total + dailyDemandMcft(city),
    );
    if (totalDemand <= 0) return const [];
    return snapshot.reservoirHistory.map((reading) {
      final stored = reading.storageByCity.values.fold<double>(
        0,
        (a, b) => a + b,
      );
      return (reading.date, stored / totalDemand);
    }).toList();
  }
}