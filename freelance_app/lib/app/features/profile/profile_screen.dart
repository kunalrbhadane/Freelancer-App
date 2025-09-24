import 'dart:io'; // Required for using the 'File' type for the avatar.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports for the Profile Feature ---
import 'package:freelance_app/app/features/profile/edit_profile_screen.dart';
import 'package:freelance_app/app/features/profile/profile_service.dart';

/// A screen that displays the freelancer's professional profile.
///
/// This screen is fully dynamic, 'watching' the [ProfileService] for any changes.
/// When the user saves their profile (including their avatar) on the [EditProfileScreen],
/// this screen will automatically rebuild to show the latest information.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // By using context.watch, this widget subscribes to the ProfileService.
    // It will automatically rebuild whenever notifyListeners() is called in the service.
    final profileService = context.watch<ProfileService>();
    final profile = profileService.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // This button navigates to the edit form screen.
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We pass all the dynamic data from the service into our header widget.
            _buildProfileHeader(
              context,
              name: profile.name,
              title: profile.title,
              avatarPath: profile.avatarImagePath,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Me', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    profile.bio,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const Divider(height: 32),
                  Text('Skills', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  // The skills list is dynamically built from the service data.
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: profile.skills.map((skill) {
                      // Prevent empty chips if user leaves extra commas.
                      if (skill.isNotEmpty) {
                        return Chip(label: Text(skill));
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                  const Divider(height: 32),
                  // This section can remain static as it's not part of the editable profile.
                  Text('Work History & Reviews', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _buildWorkHistoryItem(context, 'E-commerce App Redesign', 'Client A', 4.8),
                  _buildWorkHistoryItem(context, 'SaaS Dashboard UI', 'Client B', 5.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget that builds the visually distinct profile header.
  /// It now dynamically displays either a saved avatar image or placeholder initials.
  Widget _buildProfileHeader(BuildContext context, {
    required String name,
    required String title,
    String? avatarPath,
  }) {
    // ⭐ STAR SERVICE: Intelligent placeholder logic.
    // It takes the first letter of the first two words of the name (e.g., "Alex Doe" -> "AD").
    // This is safer than just taking the first two letters.
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').take(2).join().toUpperCase()
        : '';

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(50),
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            // The key logic: Display the FileImage if the path exists.
            backgroundImage: avatarPath != null ? FileImage(File(avatarPath)) : null,
            // If there's no backgroundImage, display the initials as a child Text widget.
            child: avatarPath == null
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              SizedBox(width: 4),
              Text('4.9 (120 Reviews)', style: TextStyle(fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  /// Helper widget to build a single static item for the work history section.
  Widget _buildWorkHistoryItem(BuildContext context, String projectTitle, String clientName, double rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(projectTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Client: $clientName'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}