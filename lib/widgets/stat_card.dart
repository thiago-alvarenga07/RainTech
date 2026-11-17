import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';


class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.delta,
    this.deltaText,
    this.higherIsBetter = true,
  });

  final String label;
  final String value;
  final IconData? icon;


  final double? delta;


  final String? deltaText;


  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Color? deltaColor;
    IconData? deltaIcon;
    if (delta != null) {
      final good = delta == 0 ? null : (delta! > 0) == higherIsBetter;
      deltaColor = good == null
          ? colors.onSurfaceVariant
          : AppTheme.riskColor(context, good ? RiskLevel.low : RiskLevel.high);
      deltaIcon = delta! > 0
          ? Icons.trending_up
          : (delta! < 0 ? Icons.trending_down : Icons.trending_flat);
    }

    return Semantics(
      container: true,
      label: '$label: $value${deltaText != null ? ', $deltaText' : ''}',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: colors.primary),
                    const SizedBox(width: AppSpacing.xs + 2),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (deltaText != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    if (deltaIcon != null)
                      Icon(deltaIcon, size: 16, color: deltaColor),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        deltaText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: deltaColor ?? colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Grade responsiva de [StatCard]s: 2 colunas no celular, 4 em telas largas.
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 4 : 2;
        final width =
            (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}