import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class ProgressTile extends StatelessWidget {
  const ProgressTile({
    super.key,
    required this.title,
    required this.ratio,
    this.caption,
    this.onTap,
  });

  final String title;
  final double ratio;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = ratio.clamp(0.0, 1.0).toDouble();
    final percent = (value * 100).toStringAsFixed(0);

    return Semantics(
      button: onTap != null,
      label: '$title: $percent por cento${caption != null ? ', $caption' : ''}',
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('$percent%'),
                    if (onTap != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: colors.surfaceContainerHighest,
                ),
                if (caption != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    caption!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}