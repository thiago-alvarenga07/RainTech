import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/water_repository.dart';
import 'models/water_snapshot.dart';
import 'screens/forecast_page.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final hasSupabaseConfig =
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  if (supabaseUrl.isNotEmpty != supabaseAnonKey.isNotEmpty) {
    throw StateError(
      'Configure SUPABASE_URL e SUPABASE_ANON_KEY juntos, ou deixe ambos vazios para usar a demonstração.',
    );
  }

  if (hasSupabaseConfig) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  runApp(
    MyApp(
      repository: WaterRepository(
        supabaseClient: hasSupabaseConfig ? Supabase.instance.client : null,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.repository});

  final WaterRepository repository;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setDarkMode(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF087E8B);

    return MaterialApp(
      title: 'RainTech',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8F8),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainNavigation(
        repository: widget.repository,
        isDarkMode: _themeMode == ThemeMode.dark,
        onDarkModeChanged: _setDarkMode,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
    required this.repository,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final WaterRepository repository;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1;
  late Future<WaterSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = widget.repository.loadSnapshot();
  }

  void _refresh() {
    setState(() {
      _snapshotFuture = widget.repository.loadSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ForecastPage(
        snapshotFuture: _snapshotFuture,
        isDemo: !widget.repository.isConnected,
        onRefresh: _refresh,
      ),
      HomePage(
        snapshotFuture: _snapshotFuture,
        isDemo: !widget.repository.isConnected,
        onRefresh: _refresh,
      ),
      SettingsPage(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
        isSupabaseConnected: widget.repository.isConnected,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Precipitação',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune),
            label: 'Tema',
          ),
        ],
      ),
    );
  }
}
