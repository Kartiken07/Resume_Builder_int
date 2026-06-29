import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Colors ───────────────────────────────────────────────────────────────

  // Primary - near-white for text/icons on dark bg
  static const Color primary = Color(0xFFE2E8F0);
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFFCBD5E1);

  // Accent - gold highlights
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentLight = Color(0xFFEDD97A);
  static const Color accentDark = Color(0xFFB8960C);

  // Secondary - muted slate
  static const Color secondary = Color(0xFF94A3B8);
  static const Color secondaryLight = Color(0xFFCBD5E1);
  static const Color secondaryDark = Color(0xFF64748B);

  // Backgrounds - deep navy (complements black sidebar)
  static const Color background = Color(0xFF1C1C2E);
  static const Color backgroundSecondary = Color(0xFF16213E);
  static const Color surface = Color(0xFF252540);
  static const Color surfaceElevated = Color(0xFF2D2D4E);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF475569);

  // Borders
  static const Color border = Color(0xFF2A2A45);
  static const Color borderLight = Color(0xFF35355A);

  // Sidebar-specific
  static const Color sidebarBg = Color(0xFF0F0F0F);
  static const Color sidebarDivider = Color(0x26FFFFFF); // white 15%
  static const Color sidebarInactiveIcon = Color(0x80FFFFFF); // white 50%
  static const Color sidebarHover = Color(0x0DFFFFFF); // white 5%
  static const Color sidebarVersionText = Color(0x66FFFFFF); // white 40%
  static const double sidebarWidth = 220;
  static const double sidebarLogoFontSize = 22;
  static const double sidebarNavFontSize = 13;
  static const double sidebarNavIconSize = 18;
  static const double sidebarNavBorderRadius = 10;

  // Chart colors
  static const Color chartPrincipal = Color(0xFFD4AF37); // gold
  static const Color chartInterest = Color(0xFF6366F1);  // indigo

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Gradients ────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF252540), Color(0xFF1C1C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient curvedBackgroundGradient = LinearGradient(
    colors: [Color(0xFF252540), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF141414), Color(0xFF0A0A0A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Typography ───────────────────────────────────────────────────────────

  static TextStyle get headingLarge => GoogleFonts.playfairDisplay(
        fontSize: 54, fontWeight: FontWeight.w700, color: textPrimary);

  static TextStyle get headingMedium => GoogleFonts.playfairDisplay(
        fontSize: 42, fontWeight: FontWeight.w600, color: textPrimary);

  static TextStyle get headingSmall => GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary);

  static TextStyle get titleLarge => GoogleFonts.montserrat(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: 0.5);

  static TextStyle get titleMedium => GoogleFonts.montserrat(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: textPrimary, letterSpacing: 0.3);

  static TextStyle get bodyLarge => GoogleFonts.montserrat(
        fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary);

  static TextStyle get bodyMedium => GoogleFonts.montserrat(
        fontSize: 14, fontWeight: FontWeight.w500, color: textSecondary);

  static TextStyle get bodySmall => GoogleFonts.montserrat(
        fontSize: 12, fontWeight: FontWeight.w400, color: textTertiary);

  static TextStyle get labelLarge => GoogleFonts.montserrat(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: textPrimary, letterSpacing: 1.2);

  static TextStyle get labelMedium => GoogleFonts.montserrat(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: textSecondary, letterSpacing: 1.2);

  static TextStyle get labelSmall => GoogleFonts.montserrat(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: textTertiary, letterSpacing: 1.0);

  // Sidebar brand text styles
  static TextStyle get sidebarBrandTitle => GoogleFonts.playfairDisplay(
        fontSize: sidebarLogoFontSize, fontWeight: FontWeight.w700,
        color: primaryLight, letterSpacing: 3);

  static TextStyle get sidebarBrandScript => GoogleFonts.greatVibes(
        fontSize: sidebarLogoFontSize, color: accent);

  static TextStyle get sidebarVersionStyle => GoogleFonts.montserrat(
        fontSize: 11, color: sidebarVersionText, letterSpacing: 1);

  // Card result text styles
  static TextStyle get cardLabelStyle => GoogleFonts.montserrat(
        color: textSecondary, fontSize: 13,
        fontWeight: FontWeight.w500, letterSpacing: 0.5);

  static TextStyle get cardValueStyle => GoogleFonts.playfairDisplay(
        fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary);

  static TextStyle get cardValueLarge => GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.w700, color: accent);

  static TextStyle get breakdownLabel => GoogleFonts.montserrat(
        color: textPrimary, fontWeight: FontWeight.w600,
        fontSize: 11, letterSpacing: 3);

  static TextStyle get breakdownLegend => GoogleFonts.montserrat(
        fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary);

  static TextStyle get decorative => GoogleFonts.greatVibes(
        fontSize: 54, color: accent, fontWeight: FontWeight.w400);

  // ─── Shadows ──────────────────────────────────────────────────────────────

  static const List<BoxShadow> shadowSmall = [
    BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x60000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> shadowXLarge = [
    BoxShadow(color: Color(0x99000000), blurRadius: 32, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> sidebarShadow = [
    BoxShadow(color: Color(0x80000000), blurRadius: 20, offset: Offset(4, 0)),
  ];

  // ─── Border Radius ────────────────────────────────────────────────────────

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusXXLarge = 32.0;

  // ─── Spacing ──────────────────────────────────────────────────────────────

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // ─── Component Sizes ──────────────────────────────────────────────────────

  static const double buttonHeight = 34.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const double cardPaddingH = 20.0;
  static const double cardPaddingV = 16.0;
  static const double cardMarginBottom = 12.0;
  static const double chartHeight = 180.0;
  static const double chartRadius = 60.0;
  static const double chartCenterRadius = 45.0;
  static const double chartSectionsSpace = 3.0;
  static const double qrContainerPadding = 12.0;
  static const double legendDotSize = 12.0;
  static const double legendSpacing = 24.0;
}
