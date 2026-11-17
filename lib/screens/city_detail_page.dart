import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../analytics/indicators.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/charts/category_bar_chart.dart';
import '../widgets/charts/chart_card.dart';
import '../widgets/charts/trend_line_chart.dart';
import '../widgets/info_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/snapshot_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/water_format.dart';
import '../state/alerts_state.dart';
import '../widgets/alert_tile.dart';

class CityDetailPage extends StatelessWidget {
  const CityDetailPage({super.key, required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cityName)),
      body: SnapshotView(
        builder: (context, snapshot) {
          final reservoir = snapshot.reservoirs
              .where((r) => r.name == cityName)
              .firstOrNull;
          if (reservoir == null) {
            return const Center(
              child: Text('Cidade não encontrada nos dados atuais.'),
            );
          }
          final fillHistory = snapshot.fillHistoryFor(cityName);
          final change7d = Indicators.change(fillHistory);
          final rain = snapshot.rainHistoryFor(cityName);
          final last14 = rain.length > 14 ? rain.sublist(rain.length - 14) : rain;
          final autonomy = DemandModel.autonomyDays(reservoir);
          final alertsState = context.watch<AlertsState>();
          final cityAlerts = alertsState.forCity(cityName);

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.page,
            children: [
              SectionHeader(
                eyebrow: 'Detalhe do indicador',
                title: cityName,
                subtitle:
                    'Dados atualizados em ${formatDate(snapshot.observedAt)}',
              ),
              const OfflineBanner(),
              const SizedBox(height: AppSpacing.lg),
              if (cityAlerts.isNotEmpty) ...[
                SubsectionTitle(
                  'Alertas desta cidade',
                  trailing: '${cityAlerts.length}',
                ),
                ...cityAlerts.map(
                  (alert) => AlertTile(
                    alert: alert,
                    review: alertsState.reviewOf(alert.id),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              StatGrid(
                children: [
                  StatCard(
                    icon: Icons.water,
                    label: 'Nível do reservatório',
                    value: formatPercent(reservoir.fillRatio),
                    delta: change7d,
                    deltaText: change7d == null
                        ? null
                        : '${formatPointsDelta(change7d)} em 7 dias',
                  ),
                  StatCard(
                    icon: Icons.hourglass_bottom,
                    label: 'Autonomia estimada',
                    value: formatDays(autonomy),
                    deltaText: 'sem chuva, consumo médio',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ChartCard(
                title: 'Nível • últimos ${fillHistory.length} dias',
                semanticSummary:
                    'Gráfico de linha do nível de $cityName, atualmente '
                    '${formatPercent(reservoir.fillRatio)}.',
                chart: TrendLineChart(
                  series: fillHistory,
                  minY: 0,
                  maxY: 1,
                  thresholds: const [
                    Indicators.criticalReserve,
                    Indicators.attentionReserve,
                  ],
                  formatValue: formatPercent,
                ),
                footer:
                    '${formatMcft(reservoir.storageMcft)} de ${formatMcft(reservoir.capacityMcft)} MCFT armazenados.',
              ),
              const SizedBox(height: AppSpacing.sm),
              ChartCard(
                title: 'Chuva diária • últimos ${last14.length} dias',
                height: 160,
                semanticSummary:
                    'Gráfico de barras da chuva em $cityName. Total de '
                    '${formatMillimeters(last14.fold<double>(0, (a, e) => a + e.$2))} no período.',
                chart: CategoryBarChart(
                  labels: [for (final e in last14) '${e.$1.day}'],
                  values: [for (final e in last14) e.$2],
                  formatValue: (v) => v.toStringAsFixed(1),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const InfoBanner(
                text:
                    'Os valores são leituras da fonte de dados e podem ter atraso ou falhas de medição.',
              ),
            ],
          );
        },
      ),
    );
  }
}