/// File Sharing project theme adapted to match the ToolHub Main Project Theme (navy and gold).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class FileSharingTheme {
  // ── Palette mapped to AppTheme ─────────────────────────────────────────────
  static const Color ink = AppTheme.background;
  static const Color surface = AppTheme.surface;
  static const Color surfaceStrong = AppTheme.surfaceElevated;
  static const Color line = AppTheme.border;
  static const Color mist = AppTheme.textSecondary;
  
  // Gradients map to Gold/Accent palette
  static const Color coral = AppTheme.accent;
  static const Color gold = AppTheme.accentLight;
  static const Color aqua = AppTheme.accent;
  static const Color sky = AppTheme.accentLight;

  // ── ThemeData ──────────────────────────────────────────────────────────────
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppTheme.accent,
      secondary: AppTheme.accentLight,
      surface: AppTheme.surface,
      onPrimary: AppTheme.background,
      onSecondary: AppTheme.background,
      onSurface: AppTheme.textPrimary,
      error: AppTheme.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTheme.background,
      textTheme: _textTheme(),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: GoogleFonts.montserrat(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: GoogleFonts.montserrat(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.montserrat(color: Colors.white.withValues(alpha: 0.38)),
        prefixIconColor: Colors.white.withValues(alpha: 0.75),
        suffixIconColor: Colors.white.withValues(alpha: 0.75),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.accentLight, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
          textStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      dividerColor: AppTheme.border,
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppTheme.accent),
    );
  }

  static TextTheme _textTheme() {
    final base = GoogleFonts.montserratTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ).apply(bodyColor: AppTheme.textPrimary, displayColor: AppTheme.textPrimary);

    return base.copyWith(
      displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 38, fontWeight: FontWeight.w700, height: 1.02, color: AppTheme.textPrimary),
      headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32, fontWeight: FontWeight.w700, height: 1.05, color: AppTheme.textPrimary),
      headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 26, fontWeight: FontWeight.w700, height: 1.08, color: AppTheme.textPrimary),
      titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 21, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
      titleMedium: GoogleFonts.montserrat(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
      bodyLarge: GoogleFonts.montserrat(
          fontSize: 16, fontWeight: FontWeight.w500, height: 1.5, color: AppTheme.textPrimary),
      bodyMedium: GoogleFonts.montserrat(
          fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: AppTheme.textSecondary),
      labelLarge: GoogleFonts.montserrat(
          fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
    );
  }
}
