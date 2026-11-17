import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_spacing.dart';
import '../models/water_snapshot.dart';
import '../state/water_data_state.dart';
import 'info_banner.dart';
import 'water_format.dart';

/// Lê o estado global dos dados e trata carregamento, erro e lista vazia.
/// Só chama [builder] quando há dados para exibir.
class SnapshotView extends StatelessWidget {
  const SnapshotView({super.key, required this.builder});

  final Widget Function(BuildContext context, WaterSnapshot snapshot) builder;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WaterDataState>();

    return switch (state.status) {
      LoadStatus.loading => Center(
        child: Semantics(
          label: 'Carregando dados',
          child: const CircularProgressIndicator(),
        ),
      ),
      LoadStatus.error => _Message(
        icon: Icons.cloud_off_outlined,
        title: 'Não foi possível carregar os dados.',
        detail: state.errorMessage,
        onRetry: state.load,
      ),
      LoadStatus.empty => _Message(
        icon: Icons.inbox_outlined,
        title: 'Ainda não há registros para exibir.',
        detail: 'Assim que a fonte de dados receber leituras, elas aparecem aqui.',
        onRetry: state.load,
      ),
      LoadStatus.success => RefreshIndicator(
        onRefresh: state.load,
        child: builder(context, state.snapshot!),
      ),
    };
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WaterDataState>();
    if (!state.isFromCache) return const SizedBox.shrink();
    final savedAt = state.cacheSavedAt;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: InfoBanner(
        icon: Icons.wifi_off,
        tone: InfoBannerTone.warning,
        text:
            'Sem conexão: exibindo os dados salvos no aparelho'
            '${savedAt != null ? ' em ${formatDate(savedAt)}' : ''}. '
            'Puxe para baixo para tentar atualizar.',
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.onRetry,
    this.detail,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (detail != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(detail!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}