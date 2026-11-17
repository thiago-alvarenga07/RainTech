import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_spacing.dart';
import '../state/settings_state.dart';
import '../widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const SectionHeader(
            eyebrow: 'Aparência',
            title: 'Tema do aplicativo',
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: SwitchListTile(
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
        ],
      ),
    );
  }
}