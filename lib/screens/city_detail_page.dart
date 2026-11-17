import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/water_snapshot.dart';
import '../widgets/info_banner.dart';
import '../widgets/progress_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/snapshot_view.dart';
import '../widgets/water_format.dart';

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
          final rainHistory = _rainHistoryFor(snapshot);

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
              const SizedBox(height: AppSpacing.xl),
              ProgressTile(
                title: 'Nível do reservatório',
                ratio: reservoir.fillRatio,
                caption:
                    '${formatMcft(reservoir.storageMcft)} de ${formatMcft(reservoir.capacityMcft)} MCFT armazenados',
              ),
              const SizedBox(height: AppSpacing.lg),
              SubsectionTitle(
                'Chuva registrada',
                trailing: 'últimos ${rainHistory.length} registros',
              ),
              ...rainHistory.reversed.map(
                (entry) => Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.grain),
                    title: Text(
                      '${weekdayLabel(entry.$1)}, ${formatDate(entry.$1)}',
                    ),
                    trailing: Text(
                      formatMillimeters(entry.$2),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
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

  List<(DateTime, double)> _rainHistoryFor(WaterSnapshot snapshot) {
    final recent = snapshot.rainfall.length > 7
        ? snapshot.rainfall.sublist(snapshot.rainfall.length - 7)
        : snapshot.rainfall;
    return recent.map((observation) {
      final reading = observation.gaugeReadings.firstWhere(
        (r) => r.name == cityName,
        orElse: () => RainGaugeReading(name: cityName, rainfallMm: 0),
      );
      return (observation.date, reading.rainfallMm);
    }).toList();
  }
}