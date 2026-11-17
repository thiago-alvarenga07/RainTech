import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../state/alerts_state.dart';
import '../../widgets/alert_tile.dart';
import '../../widgets/human_decision_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/snapshot_view.dart';

enum _Filter { all, pending, reviewed }

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: SnapshotView(
        builder: (context, _) {
          final state = context.watch<AlertsState>();
          final all = state.alerts;
          final visible = switch (_filter) {
            _Filter.all => all,
            _Filter.pending => state.pending,
            _Filter.reviewed =>
              all.where((a) => state.reviewOf(a.id) != null).toList(),
          };
          final high = all.where((a) => a.severity == RiskLevel.high).length;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.page,
            children: [
              SectionHeader(
                eyebrow: 'Alertas preditivos',
                title: '${all.length} alertas ativos',
                subtitle:
                    '$high de risco alto • ${state.pending.length} aguardando revisão',
              ),
              const OfflineBanner(),
              const SizedBox(height: AppSpacing.md),
              const HumanDecisionBanner(),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<_Filter>(
                segments: const [
                  ButtonSegment(value: _Filter.all, label: Text('Todos')),
                  ButtonSegment(value: _Filter.pending, label: Text('Pendentes')),
                  ButtonSegment(value: _Filter.reviewed, label: Text('Revisados')),
                ],
                selected: {_filter},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setState(() => _filter = selection.first),
              ),
              const SizedBox(height: AppSpacing.md),
              if (visible.isEmpty)
                _EmptyAlerts(filter: _filter)
              else
                ...visible.map(
                  (alert) =>
                      AlertTile(alert: alert, review: state.reviewOf(alert.id)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts({required this.filter});

  final _Filter filter;

  @override
  Widget build(BuildContext context) {
    final text = switch (filter) {
      _Filter.all =>
        'Nenhum alerta no momento. Os indicadores estão dentro dos limites configurados.',
      _Filter.pending => 'Todos os alertas já foram revisados.',
      _Filter.reviewed => 'Nenhum alerta revisado ainda.',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.verified_outlined,
            size: 44,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}