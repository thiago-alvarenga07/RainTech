import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.isSupabaseConnected,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final bool isSupabaseConnected;

  @override
  Widget build(BuildContext context) {
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
                isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: const Text('Modo escuro'),
              subtitle: Text(
                isDarkMode ? 'Tema escuro ativo' : 'Tema claro ativo',
              ),
              value: isDarkMode,
              onChanged: onDarkModeChanged,
            ),
          ),
        ],
      ),
    );
  }
}