import 'package:flutter/material.dart';

import '../../analytics/indicators.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/charts/category_bar_chart.dart';
import '../../widgets/charts/chart_card.dart';
import '../../widgets/charts/trend_line_chart.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/snapshot_view.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/water_format.dart';

/// Dashboard 3 — Demanda por serviço: consumo estimado e autonomia.
class DemandDashboard extends StatelessWidget {
  const DemandDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SnapshotView(
      builder: (context, snapshot) {
        final autonomy = {
          for (final r in snapshot.reservoirs)
            r.name: DemandModel.autonomyDays(r),
        };
        final history = DemandModel.regionalAutonomyHistory(snapshot);
        final regional = history.isEmpty ? 0.0 : history.last.$2;
        final change7d = Indicators.change(history);
        final totalDemand = snapshot.reservoirs.fold<double>(
          0,
          (total, r) => total + DemandModel.dailyDemandMegaliters(r.name),
        );

        Color colorFor(double days) => AppTheme.riskColor(
          context,
          days < Indicators.attentionAutonomyDays / 2
              ? RiskLevel.high
              : days < Indicators.attentionAutonomyDays
              ? RiskLevel.medium
              : RiskLevel.low,
        );

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.page.copyWith(top: AppSpacing.lg),
          children: [
            const SectionHeader(
              eyebrow: 'Demanda por serviço',
              title: 'Consumo e autonomia',
              subtitle:
                  'Quantos dias a água armazenada atende a população, sem chuva.',
            ),
            const OfflineBanner(),
            const SizedBox(height: AppSpacing.lg),
            StatGrid(
              children: [
                StatCard(
                  icon: Icons.groups_outlined,
                  label: 'População atendida',
                  value:
                      '${(DemandModel.totalPopulation / 1e6).toStringAsFixed(2)} mi',
                  deltaText: 'estimativa sintética',
                ),
                StatCard(
                  icon: Icons.local_drink_outlined,
                  label: 'Demanda diária',
                  value: '${totalDemand.toStringAsFixed(0)} mi L',
                  deltaText:
                      '${DemandModel.litersPerPersonPerDay.toStringAsFixed(0)} L/pessoa/dia',
                ),
                StatCard(
                  icon: Icons.hourglass_bottom,
                  label: 'Autonomia regional',
                  value: formatDays(regional),
                  delta: change7d,
                  deltaText: change7d == null
                      ? null
                      : '${change7d > 0 ? '+' : ''}${change7d.toStringAsFixed(0)} dias em 7 dias',
                ),
                StatCard(
                  icon: Icons.location_city_outlined,
                  label: 'Menor autonomia',
                  value: () {
                    final worst = autonomy.entries.reduce(
                      (a, b) => a.value < b.value ? a : b,
                    );
                    return worst.key;
                  }(),
                  deltaText: formatDays(
                    autonomy.values.reduce((a, b) => a < b ? a : b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ChartCard(
              title: 'Autonomia por cidade (dias)',
              subtitle:
                  'Linha tracejada: ${Indicators.attentionAutonomyDays.toStringAsFixed(0)} dias, faixa de atenção.',
              semanticSummary: autonomy.entries
                  .map((e) => '${e.key}: ${formatDays(e.value)}')
                  .join(', '),
              chart: CategoryBarChart(
                labels: [for (final city in autonomy.keys) cityShortName(city)],
                values: autonomy.values.toList(),
                barColors: [for (final days in autonomy.values) colorFor(days)],
                threshold: Indicators.attentionAutonomyDays,
                formatValue: (v) => v.toStringAsFixed(0),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ChartCard(
              title: 'Autonomia regional • histórico',
              subtitle: 'Volume total armazenado ÷ demanda diária da região.',
              semanticSummary:
                  'Gráfico de linha da autonomia regional, atualmente ${formatDays(regional)}.',
              chart: TrendLineChart(
                series: history,
                minY: 0,
                thresholds: const [Indicators.attentionAutonomyDays],
                formatValue: (v) => v.toStringAsFixed(0),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SubsectionTitle('Por cidade'),
            ...snapshot.reservoirs.map(
              (r) => Card(
                child: ListTile(
                  leading: Icon(
                    Icons.circle,
                    size: 14,
                    color: colorFor(autonomy[r.name]!),
                  ),
                  title: Text(r.name),
                  subtitle: Text(
                    '${DemandModel.dailyDemandMegaliters(r.name).toStringAsFixed(0)} mi L/dia • '
                    '${DemandModel.servedPopulation[r.name]} pessoas',
                  ),
                  trailing: Text(
                    formatDays(autonomy[r.name]!),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () => AppRoutes.openCity(context, r.name),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const InfoBanner(
              tone: InfoBannerTone.warning,
              text:
                  'População e consumo per capita são valores SINTÉTICOS para demonstração. '
                  'A autonomia ignora chuva futura, evaporação e transferências entre sistemas.',
            ),
          ],
        );
      },
    );
  }
}