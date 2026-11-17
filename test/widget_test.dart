import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raintech/app.dart';
import 'package:raintech/data/app_storage.dart';
import 'package:raintech/data/water_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> buildApp() async {
  SharedPreferences.setMockInitialValues({});
  final storage = await AppStorage.create();
  return RainTechApp(repository: WaterRepository(), storage: storage);
}

void main() {
  testWidgets('exibe o painel e navega para precipitação', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Visão geral'), findsOneWidget);
    expect(
      find.text(
        'Modo demonstração: conecte seu Supabase para usar os dados da região.',
      ),
      findsOneWidget,
    );
    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 1);
    expect(
      navigation.destinations
          .map((destination) => (destination as NavigationDestination).label)
          .toList(),
      ['Precipitação', 'Início', 'Tema'],
    );

    await tester.tap(find.text('Precipitação'));
    await tester.pumpAndSettle();

    expect(find.text('Próximos dias'), findsOneWidget);
    expect(find.text('Última leitura por cidade'), findsOneWidget);
  });

  testWidgets('abre o detalhe da cidade pela rota nomeada', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Salvador'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Salvador'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhe do indicador'.toUpperCase()), findsOneWidget);
    expect(find.text('Nível do reservatório'), findsOneWidget);
  });

  testWidgets('alterna o tema e persiste a preferência', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    expect(find.text('Tema claro ativo'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Tema escuro ativo'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('prefs.themeMode'), 'dark');
  });
}