import 'package:flutter/material.dart';

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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'APARÊNCIA',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.1,
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
