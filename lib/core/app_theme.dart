import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryGreen = Color(0xFF2E7D32); // Nature
  static const Color accentBlue = Color(0xFF2962FF);   // AI/Tech
  static const Color surfaceWhite = Color(0xFFF5F7FA); // Clean Background
  static const Color darkText = Color(0xFF1A1C1E);
  static const Color lightText = Color(0xFF757575);
  static const Color errorRed = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        secondary: accentBlue,
        surface: Colors.white,
        background: surfaceWhite,
        error: errorRed,
      ),
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
            fontSize: 32, fontWeight: FontWeight.bold, color: darkText),
        displayMedium: GoogleFonts.poppins(
            fontSize: 24, fontWeight: FontWeight.w600, color: darkText),
        titleLarge: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: darkText),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, color: darkText),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, color: lightText),
      ),

      // Card Style - Changed from CardTheme to CardThemeData
      cardTheme: CardThemeData(
        elevation: 0.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Button Styles
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: primaryGreen),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}