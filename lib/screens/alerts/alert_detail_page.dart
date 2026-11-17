import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/alert.dart';
import '../../state/alerts_state.dart';
import '../../widgets/confidence_meter.dart';
import '../../widgets/human_decision_banner.dart';
import '../../widgets/water_format.dart';

/// Detalhe do alerta: justificativa, confiança, limitações e o registro da decisão humana.
class AlertDetailPage extends StatelessWidget {
  const AlertDetailPage({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AlertsState>();
    final alert = state.byId(alertId);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: alert == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  'Este alerta não está mais ativo com os dados atuais.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _AlertBody(alert: alert, review: state.reviewOf(alert.id)),
    );
  }
}

class _AlertBody extends StatelessWidget {
  const _AlertBody({required this.alert, required this.review});

  final PredictiveAlert alert;
  final AlertReview? review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.riskColor(context, alert.severity);

    return ListView(
      padding: AppSpacing.page,
      children: [
        Text(
          '${alert.type.label.toUpperCase()} • RISCO ${alert.severityLabel.toUpperCase()}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          header: true,
          child: Text(
            alert.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${alert.city ?? 'Região'} • gerado em ${formatDate(alert.generatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const HumanDecisionBanner(),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          icon: Icons.description_outlined,
          title: 'O que foi identificado',
          child: Text(alert.summary),
        ),
        _Section(
          icon: Icons.fact_check_outlined,
          title: 'Justificativa (evidências)',
          child: _Bullets(alert.evidence),
        ),
        _Section(
          icon: Icons.speed,
          title: 'Nível de confiança',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConfidenceMeter(
                confidence: alert.confidence,
                label: alert.confidenceLabel,
              ),
              const SizedBox(height: AppSpacing.md),
              _Bullets(alert.confidenceReasons),
            ],
          ),
        ),
        _Section(
          icon: Icons.report_gmailerrorred_outlined,
          title: 'Limitações e quando não confiar',
          child: _Bullets(alert.limitations),
        ),
        _Section(
          icon: Icons.lightbulb_outline,
          title: 'Ação sugerida para avaliação',
          child: Text(alert.suggestedAction),
        ),
        if (alert.city != null) ...[
          OutlinedButton.icon(
            onPressed: () => AppRoutes.openCity(context, alert.city!),
            icon: const Icon(Icons.insights_outlined),
            label: Text('Ver dados de ${alert.city}'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _DecisionSection(alert: alert, review: review),
      ],
    );
  }
}

class _DecisionSection extends StatelessWidget {
  const _DecisionSection({required this.alert, required this.review});

  final PredictiveAlert alert;
  final AlertReview? review;

  Future<void> _decide(BuildContext context, AlertDecision decision) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _DecisionDialog(decision: decision),
    );
    if (note == null || !context.mounted) return;
    await context.read<AlertsState>().review(alert.id, decision, note);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Decisão registrada: ${decision.label}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = review;

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Sua decisão',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (current == null) ...[
              const Text(
                'Depois de analisar as evidências, registre se o alerta procede. '
                'O registro fica salvo apenas neste aparelho.',
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => _decide(context, AlertDecision.confirmed),
                icon: const Icon(Icons.check),
                label: const Text('Confirmar alerta'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _decide(context, AlertDecision.dismissed),
                icon: const Icon(Icons.close),
                label: const Text('Descartar alerta'),
              ),
            ] else ...[
              Text(
                '${current.decision.label} em ${formatDate(current.reviewedAt)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Justificativa: ${current.note}'),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () =>
                    context.read<AlertsState>().undoReview(alert.id),
                icon: const Icon(Icons.undo),
                label: const Text('Desfazer decisão'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DecisionDialog extends StatefulWidget {
  const _DecisionDialog({required this.decision});

  final AlertDecision decision;

  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirming = widget.decision == AlertDecision.confirmed;
    return AlertDialog(
      title: Text(confirming ? 'Confirmar alerta' : 'Descartar alerta'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 280,
          decoration: InputDecoration(
            labelText: 'Justificativa da decisão',
            hintText: confirming
                ? 'Ex.: confirmado com a operadora; comunicação será avaliada.'
                : 'Ex.: leitura incorreta, já corrigida pela operadora.',
          ),
          validator: (value) => (value ?? '').trim().length < 10
              ? 'Descreva o motivo com pelo menos 10 caracteres.'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}