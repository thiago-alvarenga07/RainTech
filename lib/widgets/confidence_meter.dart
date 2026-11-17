import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';

/// Barra com o nível de confiança (0–1) e o rótulo Alta/Média/Baixa.
class ConfidenceMeter extends StatelessWidget {
  const ConfidenceMeter({
    super.key,
    required this.confidence,
    required this.label,
  });

  final double confidence;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = AppTheme.riskColor(
      context,
      confidence >= 0.75
          ? RiskLevel.low
          : confidence >= 0.5
          ? RiskLevel.medium
          : RiskLevel.high,
    );
    final percent = (confidence * 100).round();
    return Semantics(
      label: 'Confiança $label, $percent por cento',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Confiança $label',
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
              const Spacer(),
              Text('$percent%'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: confidence,
            minHeight: 8,
            color: color,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: colors.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}