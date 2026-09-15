import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final tajawalText = GoogleFonts.tajawalTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.brand,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brand,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.habits,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: tajawalText.copyWith(
        displayLarge: GoogleFonts.lemonada(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.25,
        ),
        displayMedium: GoogleFonts.lemonada(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.25,
        ),
        displaySmall: GoogleFonts.lemonada(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.3,
        ),
        headlineLarge: GoogleFonts.lemonada(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.lemonada(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.35,
        ),
        headlineSmall: GoogleFonts.lemonada(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.lemonada(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleSmall: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.inkMuted,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.ink,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.inkMuted,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        labelMedium: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        labelSmall: GoogleFonts.tajawal(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.inkFaint,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          side: BorderSide(color: AppColors.ink, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.brandDeep, width: 2),
          ),
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.onAccent,
        elevation: 4,
      ),
    );
  }

  // Dark Theme aligns with warm dark paper tones
  static ThemeData get darkTheme {
    final light = lightTheme;
    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1E1C18),
      cardTheme: light.cardTheme.copyWith(
        color: const Color(0xFF262420),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: Color(0xFF38342D), width: 1),
        ),
      ),
    );
  }
}
