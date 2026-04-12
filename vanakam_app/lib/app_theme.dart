import 'package:flutter/material.dart';
import 'package:vanakam_app/constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: McColors.bgDarkStart,
      primaryColor: McColors.diamond,
      colorScheme: const ColorScheme.dark(
        primary: McColors.diamond,
        secondary: Color(0xFF8B5CF6),
        surface: McColors.surface,
        onSurface: Colors.white,
      ),
      fontFamily: 'Rajdhani',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: McColors.surface.withOpacity(0.72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'PressStart2P',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 14, color: Colors.white54),
      ),
    );
  }
}
