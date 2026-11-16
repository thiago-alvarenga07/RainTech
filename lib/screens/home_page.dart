import 'package:flutter/material.dart';

import '../models/water_snapshot.dart';
import '../widgets/snapshot_view.dart';
import '../widgets/water_format.dart';

class HomePage extends StatelessWidget {
  const HomePage({
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
        title: const Text('RainTech'),
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
          final reservePercent = snapshot.reserveRatio * 100;
          final risk = _riskFor(snapshot);
          final daysSinceUpdate = DateTime.now()
              .difference(snapshot.observedAt)
              .inDays;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              Text(
                'PAINEL DE ABASTECIMENTO',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.1,
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Visão geral',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Dados atualizados em ${formatDate(snapshot.observedAt)}',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              if (isDemo || daysSinceUpdate > 2) ...[
                const SizedBox(height: 14),
                _InfoBanner(
                  icon: isDemo ? Icons.science_outlined : Icons.schedule,
                  text: isDemo
                      ? 'Modo demonstração: conecte seu Supabase para usar os dados da região.'
                      : 'Os dados disponíveis têm mais de 2 dias; confirme a situação antes de agir.',
                ),
              ],
              const SizedBox(height: 20),
              _RiskCard(
                title: risk.$1,
                description: risk.$2,
                icon: risk.$3,
                color: risk.$4,
              ),
              const SizedBox(height: 16),
              _ReserveCard(
                reservePercent: reservePercent,
                totalStorage: snapshot.totalStorageMcft,
                totalCapacity: snapshot.totalCapacityMcft,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cidades monitoradas',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${snapshot.reservoirs.length} cidades',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...snapshot.reservoirs.asMap().entries.map(
                (entry) => _ReservoirTile(
                  reservoir: entry.value,
                  displayName: brazilianCityDisplayNames[entry.key],
                ),
              ),
              const SizedBox(height: 16),
              _InfoBanner(
                icon: Icons.info_outline,
                text: 'O nível de atenção é uma estimativa baseada no volume armazenado e na chuva recente, não um alerta oficial.',
              ),
            ],
          );
        },
      ),
    );
  }

  (String, String, IconData, Color) _riskFor(WaterSnapshot snapshot) {
    final percent = snapshot.reserveRatio * 100;
    if (percent < 25) {
      return (
        'Risco elevado de escassez',
        'O volume armazenado está baixo. Monitore os níveis e planeje medidas preventivas.',
        Icons.warning_amber_rounded,
        const Color(0xFFB42318),
      );
    }
    if (percent < 45 || (percent < 60 && snapshot.recentRainfallAverage < 2)) {
      return (
        'Atenção ao abastecimento',
        'A reserva ou a chuva recente merece acompanhamento nos próximos dias.',
        Icons.error_outline,
        const Color(0xFFB54708),
      );
    }
    return (
      'Abastecimento estável',
      'As reservas estão em uma faixa confortável. Continue acompanhando as atualizações.',
      Icons.check_circle_outline,
      const Color(0xFF067647),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.09),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReserveCard extends StatelessWidget {
  const _ReserveCard({
    required this.reservePercent,
    required this.totalStorage,
    required this.totalCapacity,
  });

  final double reservePercent;
  final double totalStorage;
  final double totalCapacity;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water, color: colors.primary),
                const SizedBox(width: 8),
                const Text('Reserva total'),
                const Spacer(),
                Text(
                  '${reservePercent.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (reservePercent / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${formatMcft(totalStorage)} de ${formatMcft(totalCapacity)} milhões de pés cúbicos (MCFT)',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservoirTile extends StatelessWidget {
  const _ReservoirTile({
    required this.reservoir,
    required this.displayName,
  });

  final Reservoir reservoir;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final percent = reservoir.fillRatio * 100;
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text('${percent.toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: reservoir.fillRatio,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: colors.surfaceContainerHighest,
            ),
            const SizedBox(height: 7),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${formatMcft(reservoir.storageMcft)} / ${formatMcft(reservoir.capacityMcft)} MCFT',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
