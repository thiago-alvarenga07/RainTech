import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raintech/app.dart';
import 'package:raintech/data/app_storage.dart';
import 'package:raintech/data/water_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raintech/widgets/alert_tile.dart';

Future<Widget> buildApp() async {
  SharedPreferences.setMockInitialValues({});
  final storage = await AppStorage.create();
  return RainTechApp(repository: WaterRepository(), storage: storage);
}

void main() {
  testWidgets('exibe a visão geral e navega pelos 3 painéis', (tester) async {
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
    expect(navigation.selectedIndex, 0);
    expect(
      navigation.destinations
          .map((destination) => (destination as NavigationDestination).label)
          .toList(),
      ['Início', 'Painéis', 'Alertas', 'Ajustes'],
    );

    await tester.tap(find.text('Painéis'));
    await tester.pumpAndSettle();
    expect(find.text('Reserva total'), findsOneWidget);

    await tester.tap(find.text('Chuva'));
    await tester.pumpAndSettle();
    expect(find.text('Média 7 dias'), findsOneWidget);

    await tester.tap(find.text('Demanda'));
    await tester.pumpAndSettle();
    expect(find.text('Consumo e autonomia'), findsOneWidget);
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
    expect(find.text('Autonomia estimada'), findsOneWidget);
  });

  testWidgets('alterna o tema e persiste a preferência', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Tema claro ativo'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Tema escuro ativo'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('prefs.themeMode'), 'dark');
  });
  
  testWidgets('abre um alerta e exige justificativa para decidir', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alertas'));
    await tester.pumpAndSettle();
    expect(find.text('A decisão final é humana'), findsOneWidget);

    await tester.tap(find.byType(AlertTile).first);
    await tester.pumpAndSettle();
    expect(find.text('Justificativa (evidências)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Limitações e quando não confiar'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Limitações e quando não confiar'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Confirmar alerta'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Confirmar alerta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Descreva o motivo com pelo menos 10 caracteres.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField),
      'Confirmado com a equipe técnica.',
    );
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();
    expect(find.text('Desfazer decisão'), findsOneWidget);
  });
}