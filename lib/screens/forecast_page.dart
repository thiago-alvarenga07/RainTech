import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/water_snapshot.dart';
import '../widgets/info_banner.dart';
import '../widgets/section_header.dart';
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
            padding: AppSpacing.page,
            children: [
              const SectionHeader(
                eyebrow: 'Tendência de chuva',
                title: 'Próximos dias',
                subtitle:
                    'Referência calculada com os registros recentes de precipitação.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                color: colors.primaryContainer,
                elevation: 0,
                child: Padding(
                  padding: AppSpacing.card,
                  child: Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 30,
                        color: colors.onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.md),
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
                            const SizedBox(height: AppSpacing.xs),
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
              const SizedBox(height: AppSpacing.xl),
              const SubsectionTitle('Última leitura por cidade'),
              ...snapshot.rainfall.last.gaugeReadings.map(
                (reading) => _GaugeTile(reading: reading),
              ),
              const SizedBox(height: AppSpacing.md),
              const SubsectionTitle(
                'Estimativa de São Paulo • próximos 5 dias',
              ),
              Text(
                'Calculada somente com as leituras recentes de chuva de São Paulo.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              ...forecast.map(
                (day) => _ForecastTile(day: day, maxRainfall: maxRain),
              ),
              const SizedBox(height: AppSpacing.sm),
              InfoBanner(
                tone: InfoBannerTone.warning,
                text: isDemo
                    ? 'Dados ilustrativos. A estimativa usa somente os registros de São Paulo; não é uma previsão meteorológica.'
                    : 'A estimativa repete a média dos últimos 7 registros de chuva de São Paulo; não é uma previsão meteorológica.',
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
  const _GaugeTile({required this.reading});

  final RainGaugeReading reading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.location_on_outlined),
        title: Text(reading.name),
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
