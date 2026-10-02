import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF111827);
  static const Color accentColor = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF5F6FA);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      primary: primaryColor,
      secondary: accentColor,
    ),
  );
}