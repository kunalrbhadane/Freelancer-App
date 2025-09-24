import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports for State Management ---
import 'package:freelance_app/app/core/theme/theme_service.dart';

// --- Imports for Navigation ---
import 'package:freelance_app/app/features/auth/login_screen.dart';
import 'package:freelance_app/app/features/profile/edit_profile_screen.dart';
import 'package:freelance_app/app/features/settings/change_password_screen.dart';
import 'package:freelance_app/app/features/settings/notification_settings_screen.dart';
import 'package:freelance_app/app/features/settings/payment_settings_screen.dart';

/// A screen that provides access to all user-configurable settings.
///
/// This screen allows the user to manage their account, toggle preferences like
/// Dark Mode, access legal information, and log out of the application.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the ThemeService to connect our switch to it. We use 'listen: true' (the default)
    // because we want the switch icon to update when the theme changes.
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSettingsSectionTitle('Account'),
          _buildSettingsTile(context, 'Edit Profile', Icons.person_outline,
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _buildSettingsTile(context, 'Change Password', Icons.lock_outline,
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          
          const Divider(),
          
          _buildSettingsSectionTitle('Preferences'),
          // ⭐ STAR SERVICE: The Dark Mode toggle switch is now fully integrated.
          SwitchListTile(
            title: const Text('Dark Mode'),
            // The icon changes depending on the current theme state.
            secondary: Icon(
              themeService.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined
            ),
            // The switch's value is bound to the service's 'isDarkMode' property.
            value: themeService.isDarkMode,
            // When the switch is flipped, we call the service's method to change the theme.
            onChanged: (bool value) {
              themeService.toggleTheme();
            },
          ),
          _buildSettingsTile(context, 'Notifications', Icons.notifications_none,
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          _buildSettingsTile(context, 'Payment Settings', Icons.payment,
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentSettingsScreen())),
          ),
          
          const Divider(),
          
          _buildSettingsSectionTitle('Support & Legal'),
          _buildSettingsTile(context, 'Help/Support', Icons.help_outline,
            () => _showInfoDialog(context, 'Help/Support', 'For support, please email support@freelanceapp.com or visit our website.'),
          ),
          _buildSettingsTile(context, 'Terms of Service', Icons.article_outlined,
            () => _showInfoDialog(context, 'Terms of Service', 'These are the terms and conditions for using our platform... (Static placeholder text).'),
          ),
          _buildSettingsTile(context, 'Privacy Policy', Icons.privacy_tip_outlined,
            () => _showInfoDialog(context, 'Privacy Policy', 'We value your privacy. Our policy outlines how we handle your data... (Static placeholder text).'),
          ),
          
          const Divider(),

          // The Logout Tile remains unchanged and fully functional.
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () {
              // Navigates to the Login screen and removes all previous routes from history.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // ⭐ STAR SERVICE: All necessary helper methods are included and correct.

  /// Helper widget for creating section titles (e.g., "Account", "Preferences").
  Widget _buildSettingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// Helper widget for creating a standard, tappable settings list tile.
  Widget _buildSettingsTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  /// Helper function to show a simple informational dialog for legal/support items.
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}