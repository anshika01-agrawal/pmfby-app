import 'package:flutter/material.dart';

class PMFBYColors {
  // Official Government of India Colors
  static const Color saffron = Color(0xFFFF9933); // India Flag Saffron
  static const Color white = Color(0xFFFFFFFF);
  static const Color indiaGreen = Color(0xFF138808); // India Flag Green
  static const Color navyBlue = Color(0xFF000080); // Ashoka Chakra Blue
  
  // PMFBY Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32); // Dark Green
  static const Color lightGreen = Color(0xFF66BB6A); // Light Green
  static const Color accentOrange = Color(0xFFFF9800); // Alert Orange
  static const Color govBlue = Color(0xFF1976D2); // Government Blue
  
  // Status Colors
  static const Color approved = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFF9800);
  static const Color rejected = Color(0xFFF44336);
  static const Color draft = Color(0xFF9E9E9E);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Government Scheme Colors
  static const Color schemeBlue = Color(0xFF0D47A1);
  static const Color schemeGold = Color(0xFFFFD700);
}

class PMFBYTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: PMFBYColors.primaryGreen,
      secondary: PMFBYColors.accentOrange,
      tertiary: PMFBYColors.govBlue,
      surface: PMFBYColors.backgroundWhite,
      background: PMFBYColors.backgroundLight,
      error: PMFBYColors.rejected,
      onPrimary: PMFBYColors.textLight,
      onSecondary: PMFBYColors.textLight,
      onSurface: PMFBYColors.textPrimary,
      onBackground: PMFBYColors.textPrimary,
    ),
    scaffoldBackgroundColor: PMFBYColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: PMFBYColors.primaryGreen,
      foregroundColor: PMFBYColors.textLight,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: PMFBYColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PMFBYColors.primaryGreen,
        foregroundColor: PMFBYColors.textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PMFBYColors.accentOrange,
      foregroundColor: PMFBYColors.textLight,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PMFBYColors.backgroundWhite,
      selectedItemColor: PMFBYColors.primaryGreen,
      unselectedItemColor: PMFBYColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PMFBYColors.backgroundWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: PMFBYColors.primaryGreen.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: PMFBYColors.primaryGreen.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PMFBYColors.primaryGreen, width: 2),
      ),
    ),
  );
}
