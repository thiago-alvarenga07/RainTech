import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/app_storage.dart';
import 'data/water_repository.dart';

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

  final storage = await AppStorage.create();

  runApp(
    RainTechApp(
      storage: storage,
      repository: WaterRepository(
        supabaseClient: hasSupabaseConfig ? Supabase.instance.client : null,
      ),
    ),
  );
}