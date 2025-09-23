import 'package:flutter/material.dart';
import 'package:freelance_app/app/features/profile/edit_profile_screen.dart';
import 'package:freelance_app/app/features/profile/profile_service.dart';
import 'package:provider/provider.dart';

/// A screen that displays the freelancer's professional profile.
///
/// This screen is fully dynamic, 'watching' the [ProfileService] for any changes.
/// When the user saves their profile on the [EditProfileScreen], this screen will
/// automatically rebuild to show the updated information.
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
          // This button now navigates to our new edit form screen.
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
            _buildProfileHeader(context, name: profile.name, title: profile.title),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Me', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(profile.bio, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const Divider(height: 32),
                  Text('Skills', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: profile.skills.map((skill) => Chip(label: Text(skill))).toList(),
                  ),
                  const Divider(height: 32),
                  // The Work History & Reviews section can remain static for now,
                  // as it's not part of the editable profile data.
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

  // --- Helper Widgets for UI construction ---

  Widget _buildProfileHeader(BuildContext context, {required String name, required String title}) {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            // In a real app, this would be a dynamic NetworkImage(profile.avatarUrl)
            backgroundColor: Colors.blue,
            child: Text('AD', style: TextStyle(fontSize: 40, color: Colors.white)),
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

  Widget _buildWorkHistoryItem(BuildContext context, String projectTitle, String clientName, double rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(projectTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Client: $clientName'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}