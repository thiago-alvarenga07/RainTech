import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/app_storage.dart';
import 'data/water_repository.dart';
import 'state/settings_state.dart';
import 'state/water_data_state.dart';
import 'state/alerts_state.dart';

/// Raiz do app: registra o estado global e configura tema e rotas.
class RainTechApp extends StatelessWidget {
  const RainTechApp({
    super.key,
    required this.repository,
    required this.storage,
  });

  final WaterRepository repository;
  final AppStorage storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsState(storage)),
        ChangeNotifierProvider(
          create: (_) => WaterDataState(repository, storage)..load(),
        ),
        ChangeNotifierProxyProvider<WaterDataState, AlertsState>(
          create: (_) => AlertsState(storage),
          update: (_, data, alerts) => alerts!..updateFrom(data),
        ),
      ],
      child: Consumer<SettingsState>(
        builder: (context, settings, _) => MaterialApp(
          title: 'RainTech',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}