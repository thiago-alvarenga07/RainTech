import 'package:flutter/material.dart';

import '../../screens/alerts/alert_detail_page.dart';
import '../../screens/city_detail_page.dart';
import '../../screens/main_navigation.dart';

/// Nomes de todas as rotas do app em um único lugar.
abstract final class AppRoutes {
  static const home = '/';
  static const cityDetail = '/cidade';
  static const alertDetail = '/alerta';


  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case cityDetail:
        final cityName = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CityDetailPage(cityName: cityName),
        );
      case alertDetail:
        final alertId = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AlertDetailPage(alertId: alertId),
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


  static Future<void> openAlert(BuildContext context, String alertId) =>
      Navigator.pushNamed(context, alertDetail, arguments: alertId);
}