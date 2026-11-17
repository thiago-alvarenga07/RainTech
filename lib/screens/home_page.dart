import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../models/water_snapshot.dart';
import '../state/water_data_state.dart';
import '../widgets/info_banner.dart';
import '../widgets/progress_tile.dart';
import '../widgets/risk_card.dart';
import '../widgets/section_header.dart';
import '../widgets/snapshot_view.dart';
import '../widgets/water_format.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.read<WaterDataState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('RainTech'),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: data.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SnapshotView(
        builder: (context, snapshot) {
          final risk = _riskFor(snapshot);
          final daysSinceUpdate = DateTime.now()
              .difference(snapshot.observedAt)
              .inDays;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.page,
            children: [
              SectionHeader(
                eyebrow: 'Painel de abastecimento',
                title: 'Visão geral',
                subtitle:
                    'Dados atualizados em ${formatDate(snapshot.observedAt)}',
              ),
              const OfflineBanner(),
              if (data.isDemo || daysSinceUpdate > 2) ...[
                const SizedBox(height: AppSpacing.md),
                InfoBanner(
                  icon: data.isDemo ? Icons.science_outlined : Icons.schedule,
                  tone: InfoBannerTone.warning,
                  text: data.isDemo
                      ? 'Modo demonstração: conecte seu Supabase para usar os dados da região.'
                      : 'Os dados disponíveis têm mais de 2 dias; confirme a situação antes de agir.',
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              RiskCard(level: risk.$1, title: risk.$2, description: risk.$3),
              const SizedBox(height: AppSpacing.sm),
              _ReserveCard(snapshot: snapshot),
              const SizedBox(height: AppSpacing.xl),
              SubsectionTitle(
                'Cidades monitoradas',
                trailing: '${snapshot.reservoirs.length} cidades',
              ),
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
                    'O nível de atenção é uma estimativa baseada no volume armazenado e na chuva recente, não um alerta oficial.',
              ),
            ],
          );
        },
      ),
    );
  }

  (RiskLevel, String, String) _riskFor(WaterSnapshot snapshot) {
    final percent = snapshot.reserveRatio * 100;
    if (percent < 25) {
      return (
        RiskLevel.high,
        'Risco elevado de escassez',
        'O volume armazenado está baixo. Monitore os níveis e planeje medidas preventivas.',
      );
    }
    if (percent < 45 || (percent < 60 && snapshot.recentRainfallAverage < 2)) {
      return (
        RiskLevel.medium,
        'Atenção ao abastecimento',
        'A reserva ou a chuva recente merece acompanhamento nos próximos dias.',
      );
    }
    return (
      RiskLevel.low,
      'Abastecimento estável',
      'As reservas estão em uma faixa confortável. Continue acompanhando as atualizações.',
    );
  }
}

class _ReserveCard extends StatelessWidget {
  const _ReserveCard({required this.snapshot});

  final WaterSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final percent = snapshot.reserveRatio * 100;
    return Semantics(
      container: true,
      label: 'Reserva total: ${percent.toStringAsFixed(0)} por cento',
      child: Card(
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Reserva total'),
                  const Spacer(),
                  Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: snapshot.reserveRatio.clamp(0.0, 1.0),
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: colors.surfaceContainerHighest,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${formatMcft(snapshot.totalStorageMcft)} de ${formatMcft(snapshot.totalCapacityMcft)} milhões de pés cúbicos (MCFT)',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}