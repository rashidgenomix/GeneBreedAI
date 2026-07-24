import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Core palette. Module-specific accent colors live in `module_theme.dart` —
/// these are the neutral/base colors shared by chrome (backgrounds, text, app bar).
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

  static const good = Color(0xFF059669);
  static const warn = Color(0xFFB45309);
  static const bad = Color(0xFFE11D48);
  static const info = Color(0xFF0284C7);
  static const locked = Color(0xFF9CA3AF);
}

/// A single 4px-based spacing scale used everywhere instead of ad-hoc magic numbers.
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Corner radii used across cards, chips, sheets.
class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

/// Named text styles so screens never hardcode font sizes/weights inline.
class AppText {
  static const pageTitle = TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.2);
  static const sectionTitle = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);
  static const cardTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
  static const body = TextStyle(fontSize: 13, height: 1.35);
  static const caption = TextStyle(fontSize: 11, color: Colors.grey);
  static const statValue = TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 16);
  static const statLabel = TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600);
}

/// Height reserved for the bottom navigation bar plus its own internal padding —
/// used to keep scrollable content from ever sitting underneath it (see AppShell).
const double kBottomNavReserve = 72;

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
        color: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg), side: BorderSide(color: AppColors.emerald900.withValues(alpha: 0.08))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
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
        color: AppColors.darkSurface.withValues(alpha: 0.95),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg), side: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      ),
    );
  }
}
