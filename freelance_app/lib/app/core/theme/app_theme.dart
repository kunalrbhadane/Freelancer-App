import 'package:flutter/material.dart';
import 'package:freelance_app/app/core/utils/app_colors.dart'; // Your main colors file

class AppTheme {
  // Private constructor to prevent instantiation.
  AppTheme._();

  // ⭐ =================== LIGHT THEME ===================
  static ThemeData get lightTheme {
    return ThemeData(
      // Core settings for Material 3 and overall brightness.
      useMaterial3: true,
      brightness: Brightness.light,

      // --- PRIMARY COLORS ---
      // PrimaryColor is a legacy property. It's better to use ColorScheme for Material 3.
      primaryColor: AppColors.primary,
      // Define a complete color scheme for better component compatibility.
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary, // Used for buttons, FABs, etc.
        secondary: AppColors.secondary, // Often used for accents
        error: AppColors.error, // The overall window background
        surface: AppColors.surface, // Background for cards, sheets, dialogs
        onPrimary: AppColors.textLight, // Text/icon color on primary color
        onSurface: AppColors.textPrimary, // Default text color
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins', // Make sure this font is added to pubspec.yaml and assets

      // --- COMPONENT THEMES (Light Mode) ---
      appBarTheme: const AppBarTheme(
        color: AppColors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins', // Ensure consistent font
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200], // A light background for chips
        labelStyle: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  // ⭐ =================== DARK THEME ===================
  static ThemeData get darkTheme {
    // Define the base colors for our dark theme.
    const darkBackgroundColor = Color(0xFF121212);
    const darkSurfaceColor = Color(0xFF1E1E1E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // --- PRIMARY COLORS (Dark Mode) ---
      primaryColor: AppColors.primaryLight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight, // A lighter blue for better contrast
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: darkSurfaceColor,
        onPrimary: AppColors.textPrimary, // Text on primary is now dark
        onSurface: AppColors.textLight, // Default text is now light
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      fontFamily: 'Poppins',

      // --- COMPONENT THEMES (Dark Mode) ---
      appBarTheme: const AppBarTheme(
        color: darkSurfaceColor,
        elevation: 1,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.textLight),
        titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textLight),
        bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textLight),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2.0),
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.withAlpha(50), // A translucent dark background for chips
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}