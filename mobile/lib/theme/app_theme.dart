import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- New Premium FinTech Colors ---
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color primaryBlueDeep = Color(0xFF3730A3);
  static const Color accentNeon = Color(0xFF14B8A6);

  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color primaryOrangeLight = Color(0xFFFFF2E6);
  static const Color secondaryOrange = Color(0xFFFD7E14);

  // Backgrounds
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF0F172A);

  // Surfaces (Cards)
  static const Color whiteSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1E293B);

  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFFA5252);
  static const Color info = Color(0xFF339AF0);

  // Text
  static const Color textDark = Color(0xFF1A1D23);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMutedDark = Color(0xFF6B7280);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // --- Amethyst Theme Colors (Manager Redesign) ---
  static const Color amethystPrimary = Color(0xFF9333EA);
  static const Color amethystPrimaryLight = Color(0xFFA855F7);
  static const Color amethystBackground = Color(0xFF0D0D17);
  static const Color amethystSurface = Color(0xFF161625);
  static const Color amethystSurfaceLighter = Color(0xFF1F1F35);
  static const Color amethystAccent = Color(0xFFD8B4FE);

  // --- Light Theme (Default for Admin/Accountants) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: secondaryOrange,
        surface: whiteSurface,
        onSurface: textDark,
        onPrimary: Colors.white,
        error: error,
      ),
      dividerColor: Colors.grey.withOpacity(0.1),
      cardTheme: CardThemeData(
        color: whiteSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      textTheme:
          GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme)
              .apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: whiteSurface,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  // --- Dark Theme (Default for Admin/Accountants) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: secondaryOrange,
        surface: darkSurface,
        onSurface: textLight,
        onPrimary: Colors.white,
        error: error,
      ),
      dividerColor: const Color(0xFF1F1F35),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF1F1F35), width: 1),
        ),
      ),
      textTheme:
          GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
              .apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textLight),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackground,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  // --- Manager Dashboard Theme (Amethyst) ---
  static ThemeData get managerTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: amethystPrimary,
      scaffoldBackgroundColor: amethystBackground,
      colorScheme: const ColorScheme.dark(
        primary: amethystPrimary,
        secondary: amethystAccent,
        surface: amethystSurface,
        onSurface: textLight,
        onPrimary: Colors.white,
        error: error,
      ),
      dividerColor: const Color(0xFF1F1F35),
      cardTheme: CardThemeData(
        color: amethystSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF1F1F35), width: 1),
        ),
      ),
      textTheme:
          GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
              .apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: amethystBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textLight),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: amethystBackground,
        selectedItemColor: amethystPrimaryLight,
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
