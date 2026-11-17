import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_spacing.dart';
import '../state/alerts_state.dart';
import '../state/settings_state.dart';
import '../widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    final alerts = context.watch<AlertsState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências')),
      body: ListView(
        key: const ValueKey('settings-list'),
        padding: AppSpacing.page,
        children: [
          const SectionHeader(
            eyebrow: 'Aparência',
            title: 'Tema do aplicativo',
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: SwitchListTile(
              key: const ValueKey('dark-mode-switch'),
              secondary: Icon(
                settings.isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: const Text('Modo escuro'),
              subtitle: Text(
                settings.isDarkMode ? 'Tema escuro ativo' : 'Tema claro ativo',
              ),
              value: settings.isDarkMode,
              onChanged: settings.setDarkMode,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            eyebrow: 'Acessibilidade',
            title: 'Ajustes de leitura',
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: SwitchListTile(
              key: const ValueKey('high-contrast-switch'),
              secondary: const Icon(Icons.contrast_outlined),
              title: const Text('Alto contraste'),
              subtitle: Text(
                settings.highContrast
                    ? 'Contraste reforçado ativo'
                    : 'Reforça o contraste de textos e componentes',
              ),
              value: settings.highContrast,
              onChanged: settings.setHighContrast,
            ),
          ),
          Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Tamanho do texto',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text('${(settings.fontScale * 100).round()}%'),
                    ],
                  ),
                  Slider(
                    key: const ValueKey('font-scale-slider'),
                    value: settings.fontScale,
                    min: SettingsState.minFontScale,
                    max: SettingsState.maxFontScale,
                    divisions: 13,
                    label: '${(settings.fontScale * 100).round()}%',
                    semanticFormatterCallback: (value) =>
                        '${(value * 100).round()} por cento',
                    onChanged: settings.setFontScale,
                  ),
                  Text(
                    'O ajuste é aplicado ao app e combinado com a escala de texto do sistema.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            eyebrow: 'Privacidade',
            title: 'Dados e consentimento',
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: AppSpacing.card,
              child: Semantics(
                container: true,
                excludeSemantics: true,
                label:
                    'Os níveis de reservatórios e chuva vêm de uma base pública e são apresentados por cidade. '
                    'Os dados são agregados, sem identificação de pessoas. A população atendida é uma estimativa sintética. '
                    'Justificativas digitadas podem conter dados pessoais e só são salvas localmente com consentimento explícito. '
                    'Não inclua identificadores pessoais.',
                child: const Text(
                  'Níveis de reservatórios e chuva vêm de uma base pública e são apresentados por cidade. '
                  'Os dados são agregados, sem identificação de pessoas. A população atendida exibida é uma estimativa sintética para demonstração. '
                  'Justificativas digitadas podem conter dados pessoais e só são salvas localmente com consentimento explícito. Não inclua identificadores pessoais.',
                ),
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              key: const ValueKey('review-storage-consent'),
              secondary: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Salvar avaliações neste dispositivo'),
              subtitle: const Text(
                'Autorizo salvar decisões e justificativas de alertas somente neste aparelho. '
                'Elas não são enviadas. Não inclua dados pessoais.',
              ),
              value: alerts.canPersistReviews,
              onChanged: alerts.setReviewStorageConsent,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'Sem consentimento, as avaliações ficam apenas durante a sessão. Você pode revogar a autorização a qualquer momento; os dados locais serão apagados.',
            ),
          ),
        ],
      ),
    );
  }
}
