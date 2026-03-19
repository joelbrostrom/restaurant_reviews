import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NordBiteTheme {
  // Vibrant, appetizing palette
  static const cream = Color(0xFFFEF2F2);
  static const coral = Color(0xFFDC2626);
  static const coralLight = Color(0xFFF87171);
  static const charcoal = Color(0xFF450A0A);
  static const basilGreen = Color(0xFF16A34A);
  static const gold = Color(0xFFCA8A04);
  static const softGray = Color(0xFFFEF2F2);
  static const warmWhite = Color(0xFFFFFBF7);
  static const cardWhite = Color(0xFFFFFFFF);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: coral,
        onPrimary: Colors.white,
        secondary: basilGreen,
        onSecondary: Colors.white,
        tertiary: gold,
        onTertiary: Colors.white,
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
        surface: cardWhite,
        onSurface: charcoal,
        surfaceContainerHighest: softGray,
      ),
      scaffoldBackgroundColor: warmWhite,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: charcoal,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: charcoal.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: cardWhite,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: coral.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.karla(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: BorderSide(color: charcoal.withValues(alpha: 0.08)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: coral,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.karla(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: coral,
          side: BorderSide(color: coral.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.karla(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: charcoal.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: charcoal.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: coral, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.karla(
          color: charcoal.withValues(alpha: 0.35),
          fontSize: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: charcoal.withValues(alpha: 0.06),
        thickness: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: charcoal.withValues(alpha: 0.12),
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        color: charcoal,
        letterSpacing: -0.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: charcoal,
        letterSpacing: -0.3,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: charcoal,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: charcoal,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: charcoal,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.karla(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: charcoal,
      ),
      titleLarge: GoogleFonts.karla(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: charcoal,
      ),
      titleMedium: GoogleFonts.karla(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: charcoal,
      ),
      bodyLarge: GoogleFonts.karla(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: charcoal,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.karla(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: charcoal,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.karla(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: charcoal.withValues(alpha: 0.6),
        height: 1.4,
      ),
      labelLarge: GoogleFonts.karla(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: charcoal,
        letterSpacing: 0.3,
      ),
    );
  }
}
