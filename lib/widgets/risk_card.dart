import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_theme.dart';

class RiskCard extends StatelessWidget {
  const RiskCard({
    super.key,
    required this.level,
    required this.title,
    required this.description,
    this.onTap,
  });

  final RiskLevel level;
  final String title;
  final String description;
  final VoidCallback? onTap;

  IconData get _icon => switch (level) {
    RiskLevel.high => Icons.warning_amber_rounded,
    RiskLevel.medium => Icons.error_outline,
    RiskLevel.low => Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(context, level);
    return Card(
      color: color.withValues(alpha: 0.10),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, color: color, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(description),
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}