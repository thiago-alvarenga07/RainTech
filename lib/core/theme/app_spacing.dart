import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  static const double radius = 14;

  static const EdgeInsets page = EdgeInsets.fromLTRB(xl, xs, xl, xxl);

  static const EdgeInsets card = EdgeInsets.all(18);
}