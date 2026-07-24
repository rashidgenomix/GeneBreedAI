import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald700 = Color(0xFF047857);
  static const emerald800 = Color(0xFF065F46);
  static const emerald900 = Color(0xFF064E3B);
  static const lime400 = Color(0xFFA3E635);
  static const amber500 = Color(0xFFF59E0B);
  static const rose500 = Color(0xFFF43F5E);
  static const sky500 = Color(0xFF0EA5E9);
  static const darkBg = Color(0xFF0B1512);
  static const darkSurface = Color(0xFF10201A);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.emerald600, brightness: Brightness.light),
      scaffoldBackgroundColor: AppColors.emerald50,
      textTheme: GoogleFonts.interTextTheme(),
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(backgroundColor: AppColors.emerald50, foregroundColor: const Color(0xFF10231B), elevation: 0),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.emerald900.withValues(alpha: 0.08))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.emerald500, brightness: Brightness.dark),
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.darkBg, foregroundColor: Color(0xFFE7F3ED), elevation: 0),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface.withValues(alpha: 0.9),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
    );
  }
}
