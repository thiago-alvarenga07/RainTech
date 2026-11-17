import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../analytics/indicators.dart';
import '../../core/theme/app_spacing.dart';
import '../../state/water_data_state.dart';
import '../../widgets/charts/category_bar_chart.dart';
import '../../widgets/charts/chart_card.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/snapshot_view.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/water_format.dart';

/// Dashboard 2 — Clima local: precipitação recente e referência.
class RainDashboard extends StatelessWidget {
  const RainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDemo = context.read<WaterDataState>().isDemo;
    return SnapshotView(
      builder: (context, snapshot) {
        final daily = snapshot.rainfall.map((o) => o.regionalAverageMm).toList();
        final last14 = snapshot.rainfall.length > 14
            ? snapshot.rainfall.sublist(snapshot.rainfall.length - 14)
            : snapshot.rainfall;
        final previous7 = daily.length >= 14
            ? Indicators.average(daily.sublist(daily.length - 14, daily.length - 7))
            : null;
        final recent7 = snapshot.recentRainfallAverage;
        final dryStreak = Indicators.dryStreak(daily);
        final total = daily.fold<double>(0, (a, b) => a + b);
        final latest = snapshot.rainfall.last;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.page.copyWith(top: AppSpacing.lg),
          children: [
            const SectionHeader(
              eyebrow: 'Clima local',
              title: 'Chuva',
              subtitle: 'Precipitação média registrada nas 4 cidades.',
            ),
            const OfflineBanner(),
            const SizedBox(height: AppSpacing.lg),
            StatGrid(
              children: [
                StatCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Média 7 dias',
                  value: formatMillimeters(recent7),
                  delta: previous7 == null ? null : recent7 - previous7,
                  deltaText: previous7 == null
                      ? null
                      : 'semana anterior: ${formatMillimeters(previous7)}',
                ),
                StatCard(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Dias secos seguidos',
                  value: '$dryStreak',
                  delta: dryStreak.toDouble(),
                  higherIsBetter: false,
                  deltaText: 'chuva < 1 mm/dia',
                ),
                StatCard(
                  icon: Icons.calendar_month_outlined,
                  label: 'Acumulado',
                  value: formatMillimeters(total),
                  deltaText: 'em ${daily.length} dias',
                ),
                StatCard(
                  icon: Icons.thunderstorm_outlined,
                  label: 'Maior registro',
                  value: formatMillimeters(
                    daily.fold<double>(0, (a, b) => b > a ? b : a),
                  ),
                  deltaText: 'média regional diária',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ChartCard(
              title: 'Chuva diária • últimos ${last14.length} dias',
              subtitle: 'Média das 4 cidades, em milímetros.',
              semanticSummary:
                  'Gráfico de barras da chuva diária. Média de '
                  '${formatMillimeters(recent7)} por dia na última semana e '
                  '$dryStreak dias secos seguidos.',
              chart: CategoryBarChart(
                labels: [for (final o in last14) '${o.date.day}'],
                values: [for (final o in last14) o.regionalAverageMm],
                formatValue: (v) => v.toStringAsFixed(1),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ChartCard(
              title: 'Última leitura por cidade',
              subtitle: formatDate(latest.date),
              height: 150,
              semanticSummary: latest.gaugeReadings
                  .map((r) => '${r.name}: ${formatMillimeters(r.rainfallMm)}')
                  .join(', '),
              chart: CategoryBarChart(
                labels: [
                  for (final r in latest.gaugeReadings) cityShortName(r.name),
                ],
                values: [for (final r in latest.gaugeReadings) r.rainfallMm],
                formatValue: (v) => v.toStringAsFixed(1),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InfoBanner(
              tone: InfoBannerTone.warning,
              text:
                  '${isDemo ? 'Dados ilustrativos. ' : ''}'
                  'Referência para os próximos dias: cerca de '
                  '${formatMillimeters(recent7)}/dia (média móvel de 7 dias). '
                  'Isto NÃO é uma previsão meteorológica; consulte o serviço oficial de meteorologia.',
            ),
          ],
        );
      },
    );
  }
}