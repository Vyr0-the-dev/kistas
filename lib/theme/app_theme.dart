import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.sand,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepTeal,
      primary: AppColors.deepTeal,
      secondary: AppColors.coral,
      surface: AppColors.card,
      background: AppColors.sand,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.ink,
      onBackground: AppColors.ink,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.ink,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.sand,
      elevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
    ),
    dividerColor: AppColors.line,
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
