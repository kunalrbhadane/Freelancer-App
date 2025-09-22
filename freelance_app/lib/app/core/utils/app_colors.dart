import 'package:flutter/material.dart';

// You can name this class anything you want, e.g., AppColors, AppPalette, etc.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // --- PRIMARY COLORS ---
  static const Color primary = Color(0xFF0D47A1); // A deep blue
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);

  // --- SECONDARY COLORS ---
  static const Color secondary = Color(0xFFF9A825); // A warm yellow/gold
  
  // --- TEXT COLORS ---
  static const Color textPrimary = Color(0xFF212121); // Almost black
  static const Color textSecondary = Color(0xFF757575); // Grey for subtitles
  static const Color textLight = Colors.white;

  // --- STATUS & NOTIFICATION COLORS ---
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFD32F2F);   // Red
  static const Color info = Color(0xFF1976D2);    // Blue

  // --- BACKGROUND COLORS ---
  static const Color background = Color(0xFFF5F5F5); // Very light grey
  static const Color surface = Colors.white;        // For cards, sheets, etc.
  static const Color divider = Color(0xFFE0E0E0);
}