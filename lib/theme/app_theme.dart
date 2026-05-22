import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const darkBlue = Color(0xFF0B2240);
  static const blue = Color(0xFF123A63);
  static const orange = Color(0xFFF59E0B);
  static const scaffold = Color(0xFFF5F7FA);

  static ThemeData get light => _base(
    ColorScheme.fromSeed(
      seedColor: darkBlue,
      primary: darkBlue,
      secondary: orange,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get dark => _base(
    ColorScheme.fromSeed(
      seedColor: darkBlue,
      primary: const Color(0xFF8FB9E8),
      secondary: orange,
      surface: const Color(0xFF101827),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData _base(ColorScheme scheme) {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.brightness == Brightness.light
          ? scaffold
          : const Color(0xFF0B1220),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
