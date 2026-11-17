import 'package:flutter/material.dart';

import '../../screens/city_detail_page.dart';
import '../../screens/main_navigation.dart';

/// Nomes de todas as rotas do app em um único lugar.
abstract final class AppRoutes {
  static const home = '/';
  static const cityDetail = '/cidade';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case cityDetail:
        final cityName = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CityDetailPage(cityName: cityName),
        );
      case home:
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainNavigation(),
        );
    }
  }

  static Future<void> openCity(BuildContext context, String cityName) =>
      Navigator.pushNamed(context, cityDetail, arguments: cityName);
}