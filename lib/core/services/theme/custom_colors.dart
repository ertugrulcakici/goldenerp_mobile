import 'package:flutter/material.dart';

abstract class CustomColors {
  static const Color primaryColor = Color(0xFF0E689A);
  static const String primaryColorHex = '#0E689A';
  static const primarySwatch = MaterialColor(0xFF0E689A, <int, Color>{
    50: Color.fromRGBO(14, 104, 154, 0.1),
    100: Color.fromRGBO(14, 104, 154, 0.2),
    200: Color.fromRGBO(14, 104, 154, 0.3),
    300: Color.fromRGBO(14, 104, 154, 0.4),
    400: Color.fromRGBO(14, 104, 154, 0.5),
    500: Color.fromRGBO(14, 104, 154, 0.6),
    600: Color.fromRGBO(14, 104, 154, 0.7),
    700: Color.fromRGBO(14, 104, 154, 0.8),
    800: Color.fromRGBO(14, 104, 154, 0.9),
    900: Color.fromRGBO(14, 104, 154, 1),
  });

  static const secondaryColor = Color(0xFF449BC6);
}
