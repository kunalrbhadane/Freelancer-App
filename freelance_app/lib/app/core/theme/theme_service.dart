import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The central state management service for handling the app's theme.
///
/// This service holds the current theme mode (Light, Dark, or System),
/// provides a method to toggle it, and handles saving/loading the user's
/// preference to the device's local storage.
class ThemeService extends ChangeNotifier {
  static const _themeStorageKey = 'app_theme_mode';
  ThemeMode _themeMode = ThemeMode.system; // Default to following the system's setting.

  /// Provides safe, read-only access to the current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Indicates whether the app is currently in dark mode.
  /// This is useful for UI elements that need to adapt based on the theme.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// The constructor immediately loads the saved theme preference upon app startup.
  ThemeService() {
    _loadTheme();
  }

  /// Toggles the theme between Light and Dark mode and saves the new preference.
  void toggleTheme() {
    // If it's currently dark, switch to light. Otherwise, switch to dark.
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveTheme(); // Save the new choice.
    notifyListeners(); // Notify all listening widgets to rebuild with the new theme.
  }

  /// Asynchronously saves the current theme mode to local storage.
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // We save the enum's name ('light' or 'dark') as a string.
    await prefs.setString(_themeStorageKey, _themeMode.name);
  }

  /// Asynchronously loads the saved theme preference from local storage.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeName = prefs.getString(_themeStorageKey);

    if (savedThemeName != null) {
      // Find the ThemeMode enum value that matches the saved string name.
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == savedThemeName,
        orElse: () => ThemeMode.system, // Fallback to system default
      );
    }
    // Notify listeners after loading to ensure the app starts with the correct theme.
    notifyListeners();
  }
}