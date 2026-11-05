import 'package:flutter/material.dart';

class AppTheme {
  // Google Material 3 Dynamic Tonal Palette (Dark Mode Base)
  static const Color surface = Color(0xFF121316);
  static const Color surfaceDim = Color(0xFF0E0F12);
  static const Color surfaceContainerLow = Color(0xFF1A1B1F);
  static const Color surfaceContainer = Color(0xFF212328);
  static const Color surfaceContainerHigh = Color(0xFF2B2D33);
  static const Color surfaceContainerHighest = Color(0xFF36383E);
  static const Color outline = Color(0xFF44474E);
  static const Color outlineVariant = Color(0xFF2E3036);

  // Google Brand Accents
  static const Color primaryBlue = Color(0xFF8AB4F8);
  static const Color primaryContainer = Color(0xFF1A73E8);
  static const Color successGreen = Color(0xFF81C995);
  static const Color successContainer = Color(0xFF137333);
  static const Color warningAmber = Color(0xFFFDD663);
  static const Color warningContainer = Color(0xFFB06000);
  static const Color alertRed = Color(0xFFF28B82);
  static const Color alertContainer = Color(0xFFC5221F);

  // Text Colors
  static const Color onSurface = Color(0xFFE3E3E3);
  static const Color onSurfaceVariant = Color(0xFFC4C7C5);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primaryBlue,
        primaryContainer: primaryContainer,
        secondary: successGreen,
        secondaryContainer: successContainer,
        error: alertRed,
        errorContainer: alertContainer,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: const Color(0xFF003063),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: surfaceContainerHighest,
          foregroundColor: onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
      ),
    );
  }
}
