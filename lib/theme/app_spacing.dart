import 'package:flutter/material.dart';

class AppSpacing {
  static double base(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width < 360) return 8; // celular pequeno
    if (width < 600) return 12; // celular normal
    if (width < 900) return 16; // tablet
    return 20; // telas grandes
  }

  static double small(BuildContext context) => base(context) * 0.6;
  static double medium(BuildContext context) => base(context);
  static double large(BuildContext context) => base(context) * 1.5;
}

class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}