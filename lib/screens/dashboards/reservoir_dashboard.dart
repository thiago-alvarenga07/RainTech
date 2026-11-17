import 'package:flutter/material.dart';

import '../../analytics/indicators.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/charts/chart_card.dart';
import '../../widgets/charts/trend_line_chart.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/progress_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/snapshot_view.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/water_format.dart';

/// Dashboard 1 — Recursos hídricos: volume armazenado e tendência.
class ReservoirDashboard extends StatelessWidget {
  const ReservoirDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SnapshotView(
      builder: (context, snapshot) {
        final history = snapshot.reserveRatioHistory;
        final change7d = Indicators.change(history);
        final slope = Indicators.slope(history.map((e) => e.$2).toList());
        final critical = [...snapshot.reservoirs]
          ..sort((a, b) => a.fillRatio.compareTo(b.fillRatio));

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.page.copyWith(top: AppSpacing.lg),
          children: [
            const SectionHeader(
              eyebrow: 'Recursos hídricos',
              title: 'Reservatórios',
              subtitle: 'Volume armazenado em relação à capacidade total.',
            ),
            const OfflineBanner(),
            const SizedBox(height: AppSpacing.lg),
            StatGrid(
              children: [
                StatCard(
                  icon: Icons.water,
                  label: 'Reserva total',
                  value: formatPercent(snapshot.reserveRatio),
                  delta: change7d,
                  deltaText: change7d == null
                      ? null
                      : '${formatPointsDelta(change7d)} em 7 dias',
                ),
                StatCard(
                  icon: Icons.show_chart,
                  label: 'Tendência (30 dias)',
                  value: '${formatPointsDelta(slope)}/dia',
                  delta: slope,
                  deltaText: slope < 0 ? 'em queda' : 'estável ou subindo',
                ),
                StatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Cidade mais crítica',
                  value: critical.first.name,
                  deltaText: '${formatPercent(critical.first.fillRatio)} cheio',
                ),
                StatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Volume armazenado',
                  value: formatMcft(snapshot.totalStorageMcft),
                  deltaText:
                      'de ${formatMcft(snapshot.totalCapacityMcft)} MCFT',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ChartCard(
              title: 'Reserva total • últimos ${history.length} dias',
              subtitle:
                  'Linhas tracejadas: faixa de atenção (45%) e crítica (25%).',
              semanticSummary:
                  'Gráfico de linha da reserva total. Começa em '
                  '${history.isEmpty ? '-' : formatPercent(history.first.$2)} '
                  'e termina em ${formatPercent(snapshot.reserveRatio)}.',
              chart: TrendLineChart(
                series: history,
                minY: 0,
                maxY: 1,
                thresholds: const [
                  Indicators.criticalReserve,
                  Indicators.attentionReserve,
                ],
                formatValue: formatPercent,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SubsectionTitle('Por cidade', trailing: 'toque para detalhes'),
            ...snapshot.reservoirs.map(
              (reservoir) => ProgressTile(
                title: reservoir.name,
                ratio: reservoir.fillRatio,
                caption:
                    '${formatMcft(reservoir.storageMcft)} / ${formatMcft(reservoir.capacityMcft)} MCFT',
                onTap: () => AppRoutes.openCity(context, reservoir.name),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const InfoBanner(
              text:
                  'Tendência calculada por regressão linear simples sobre o histórico. '
                  'Não considera chuvas futuras, captação extra ou manobras da operadora.',
            ),
          ],
        );
      },
    );
  }
}