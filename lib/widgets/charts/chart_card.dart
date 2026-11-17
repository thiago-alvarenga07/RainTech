import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.semanticSummary,
    required this.chart,
    this.subtitle,
    this.footer,
    this.height = 190,
  });

  final String title;
  final String? subtitle;
  final String semanticSummary;
  final Widget chart;
  final String? footer;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!, style: muted),
            ],
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              label: semanticSummary,
              excludeSemantics: true,
              child: SizedBox(height: height, child: chart),
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(footer!, style: muted),
            ],
          ],
        ),
      ),
    );
  }
}