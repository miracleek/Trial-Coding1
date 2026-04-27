import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette from DESIGN.md
  static const Color background = Color(0xFF121414);
  static const Color surface = Color(0xFF1E2020);
  static const Color surfaceHigh = Color(0xFF282A2B);
  
  static const Color primary = Color(0xFFA3FF00); // Electric Lime
  static const Color onPrimary = Color(0xFF102000);
  
  static const Color danger = Color(0xFFFF4D4D);
  static const Color success = Color(0xFFA3FF00);
  static const Color secondaryDark = Color(0xFF122B22); // Deep Emerald
  
  static const Color textMain = Color(0xFFE2E2E2);
  static const Color textMuted = Color(0xFFC0CAAD);
  static const Color borderSide = Color(0xFF333535);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        surface: surface,
        onSurface: textMain,
        error: danger,
        background: background,
        onBackground: textMain,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -0.02, color: textMain),
        displayMedium: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700, color: textMain),
        displaySmall: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: textMain),
        bodyLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: textMain),
        bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textMain),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: textMain),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textMain),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSide, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderSide),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderSide),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: textMuted),
        hintStyle: GoogleFonts.inter(color: textMuted),
      ),
    );
  }
}
