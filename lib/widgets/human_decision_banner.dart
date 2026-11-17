import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class HumanDecisionBanner extends StatelessWidget {
  const HumanDecisionBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const text =
        'Os alertas são gerados automaticamente e servem apenas como apoio. '
        'Nenhuma medida é tomada pelo app: a decisão final é sempre de uma pessoa responsável.';
    return Semantics(
      container: true,
      label: 'Aviso importante. $text',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: colors.primary, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.person_pin_outlined, color: colors.onPrimaryContainer),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A decisão final é humana',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}