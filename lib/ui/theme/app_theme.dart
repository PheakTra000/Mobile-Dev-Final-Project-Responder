import 'package:flutter/material.dart';

class AppTheme {
  static Color primary = const Color(0xFF2AA9DF);
  static Color background = const Color(0xFF000000);
  static Color surface = const Color(0xFF1A1A1A);
  static Color card = const Color(0xFF1E1E1E);
  static Color textPrimary = const Color(0xFFFFFFFF);
  static Color textSecondary = const Color(0xFF9E9E9E);
  static Color error = const Color(0xFFEF5350);

  static TextStyle heading = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle paragraph = TextStyle(
    color: textPrimary,
    fontSize: 14,
  );
}
