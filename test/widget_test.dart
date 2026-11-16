import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raintech/data/water_repository.dart';
import 'package:raintech/main.dart';

void main() {
  testWidgets('exibe o painel e navega para precipitação', (tester) async {
    await tester.pumpWidget(MyApp(repository: WaterRepository()));
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
    await tester.scrollUntilVisible(
      find.text('São Paulo'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('Poondi'), findsNothing);

    await tester.tap(find.text('Precipitação'));
    await tester.pumpAndSettle();

    expect(find.text('Próximos dias'), findsOneWidget);
    expect(find.text('Última leitura por cidade'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Estimativa de São Paulo • próximos 5 dias'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Estimativa de São Paulo • próximos 5 dias'), findsOneWidget);
    expect(
      find.text(
        'Calculada somente com as leituras recentes de chuva de São Paulo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('alterna o tema claro e escuro', (tester) async {
    await tester.pumpWidget(MyApp(repository: WaterRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    expect(find.text('Tema claro ativo'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Tema escuro ativo'), findsOneWidget);
  });
}
