import 'package:flutter/material.dart';

import '../models/water_snapshot.dart';
import '../widgets/snapshot_view.dart';
import '../widgets/water_format.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({
    super.key,
    required this.snapshotFuture,
    required this.isDemo,
    required this.onRefresh,
  });

  final Future<WaterSnapshot> snapshotFuture;
  final bool isDemo;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Precipitação'),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SnapshotView(
        snapshotFuture: snapshotFuture,
        onRefresh: onRefresh,
        builder: (snapshot) {
          final forecast = _estimateNextDays(snapshot);
          final maxRain = forecast.fold<double>(
            0,
            (maximum, day) =>
                day.rainfallMm > maximum ? day.rainfallMm : maximum,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              Text(
                'TENDÊNCIA DE CHUVA',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.1,
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Próximos dias',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Referência calculada com os registros recentes de precipitação.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Card(
                color: colors.primaryContainer,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 30,
                        color: colors.onPrimaryContainer,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Média recente em São Paulo',
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatMillimeters(
                                snapshot.recentSaoPauloRainfallAverage,
                              ),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              'por dia, nos últimos registros',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onPrimaryContainer),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Última leitura por cidade',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...snapshot.rainfall.last.gaugeReadings.asMap().entries.map(
                (entry) => _GaugeTile(
                  reading: entry.value,
                  displayName: brazilianCityDisplayNames[entry.key],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Estimativa de São Paulo • próximos 5 dias',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Calculada somente com as leituras recentes de chuva de São Paulo.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              ...forecast.map(
                (day) => _ForecastTile(day: day, maxRainfall: maxRain),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.onTertiaryContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isDemo
                            ? 'Dados ilustrativos. A estimativa usa somente os registros de São Paulo; não é uma previsão meteorológica.'
                            : 'A estimativa repete a média dos últimos 7 registros de chuva de São Paulo; não é uma previsão meteorológica.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onTertiaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_ForecastDay> _estimateNextDays(WaterSnapshot snapshot) {
    final average = snapshot.recentSaoPauloRainfallAverage;
    final today = DateTime.now();
    return List.generate(5, (index) {
      final date = DateTime(today.year, today.month, today.day + index + 1);
      return _ForecastDay(date: date, rainfallMm: average);
    });
  }
}

class _GaugeTile extends StatelessWidget {
  const _GaugeTile({
    required this.reading,
    required this.displayName,
  });

  final RainGaugeReading reading;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.location_on_outlined),
        title: Text(displayName),
        trailing: Text(
          formatMillimeters(reading.rainfallMm),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ForecastDay {
  const _ForecastDay({required this.date, required this.rainfallMm});

  final DateTime date;
  final double rainfallMm;
}

class _ForecastTile extends StatelessWidget {
  const _ForecastTile({required this.day, required this.maxRainfall});

  final _ForecastDay day;
  final double maxRainfall;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = maxRainfall <= 0 ? 0.0 : day.rainfallMm / maxRainfall;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekdayLabel(day.date).toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Text(
                    '${day.date.day}/${day.date.month}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              day.rainfallMm > 0 ? Icons.grain : Icons.wb_sunny_outlined,
              color: day.rainfallMm > 0
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 54,
              child: Text(
                formatMillimeters(day.rainfallMm),
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
