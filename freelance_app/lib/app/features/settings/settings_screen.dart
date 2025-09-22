import 'package:flutter/material.dart';

// --- Imports for Navigation ---
import 'package:freelance_app/app/features/auth/login_screen.dart'; // For the logout function
import 'package:freelance_app/app/features/profile/edit_profile_screen.dart';
import 'package:freelance_app/app/features/settings/change_password_screen.dart';
import 'package:freelance_app/app/features/settings/notification_settings_screen.dart';
import 'package:freelance_app/app/features/settings/payment_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSettingsSectionTitle('Account'),
          _buildSettingsTile(
            context,
            'Edit Profile',
            Icons.person_outline,
            // Navigates to the Edit Profile screen
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _buildSettingsTile(
            context,
            'Change Password',
            Icons.lock_outline,
            // Navigates to the Change Password screen
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          
          const Divider(),
          
          _buildSettingsSectionTitle('Preferences'),
          _buildSettingsTile(
            context,
            'Notifications',
            Icons.notifications_none,
            // Navigates to the Notification Settings screen
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          _buildSettingsTile(
            context,
            'Payment Settings',
            Icons.payment,
            // Navigates to the Payment Settings screen
            () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentSettingsScreen())),
          ),
          
          const Divider(),
          
          _buildSettingsSectionTitle('Support & Legal'),
          _buildSettingsTile(
            context,
            'Help/Support',
            Icons.help_outline,
            // Shows an informational dialog
            () => _showInfoDialog(context, 'Help/Support', 'For support, please email support@freelanceapp.com or visit our website.'),
          ),
          _buildSettingsTile(
            context,
            'Terms of Service',
            Icons.article_outlined,
            // Shows an informational dialog
            () => _showInfoDialog(context, 'Terms of Service', 'These are the terms and conditions for using our platform... (Static placeholder text).'),
          ),
          _buildSettingsTile(
            context,
            'Privacy Policy',
            Icons.privacy_tip_outlined,
            // Shows an informational dialog
            () => _showInfoDialog(context, 'Privacy Policy', 'We value your privacy. Our policy outlines how we handle your data... (Static placeholder text).'),
          ),
          
          const Divider(),

          // --- LOGOUT TILE ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // This is the correct way to log out.
              // It pushes the LoginScreen and removes all other routes
              // from the navigation stack, so the user can't go back.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false, // This predicate removes all routes.
              );
            },
          ),
        ],
      ),
    );
  }

  /// Helper widget for creating section titles.
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

  /// Helper widget for creating a tappable settings list tile.
  Widget _buildSettingsTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  /// Helper function to show a simple informational dialog.
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView( // Prevents overflow if content is long
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