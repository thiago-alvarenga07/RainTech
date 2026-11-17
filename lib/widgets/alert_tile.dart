import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';
import '../models/alert.dart';

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, this.review});

  final PredictiveAlert alert;
  final AlertReview? review;

  IconData get _icon => switch (alert.type) {
    AlertType.lowReserve => Icons.water_damage_outlined,
    AlertType.criticalProjection => Icons.trending_down,
    AlertType.drySpell => Icons.wb_sunny_outlined,
    AlertType.lowAutonomy => Icons.hourglass_bottom,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.riskColor(context, alert.severity);
    final status = review == null ? 'Aguardando revisão' : review!.decision.label;

    return Semantics(
      button: true,
      label:
          'Alerta ${alert.severityLabel}: ${alert.title}. '
          '${alert.city ?? 'Região'}. Confiança ${alert.confidenceLabel}. $status.',
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => AppRoutes.openAlert(context, alert.id),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 5)),
            ),
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${alert.type.label} • ${alert.city ?? 'Região'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _Chip(text: 'Risco ${alert.severityLabel}', color: color),
                          _Chip(
                            text: 'Confiança ${alert.confidenceLabel}',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          _Chip(
                            text: status,
                            color: review == null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}