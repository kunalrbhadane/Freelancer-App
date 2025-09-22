import 'package:flutter/material.dart';

// Import the data model and the edit screen
import 'package:freelance_app/app/features/profile/user_profile_model.dart';
import 'package:freelance_app/app/features/profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // This static object acts as our database for this screen.
  // All UI elements will pull their data from here.
  final UserProfile userProfile = UserProfile(
    name: 'Alex Doe',
    title: 'Senior Flutter Developer',
    avatarUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?Text=A',
    bio:
        'Creative and detail-oriented Flutter developer with over 5 years of experience in mobile and web application design. Proficient in Dart, GetX, and Firebase, with a passion for creating smooth and intuitive user interfaces.',
    averageRating: 4.9,
    totalReviews: 120,
    skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'GetX State Management', 'Agile Methodologies'],
    workHistory: [
      WorkHistoryItem(projectTitle: 'E-commerce App Redesign', clientName: 'Shopify', rating: 4.8),
      WorkHistoryItem(projectTitle: 'SaaS Dashboard UI', clientName: 'TechCorp', rating: 5.0),
      WorkHistoryItem(projectTitle: 'Fitness Tracker App', clientName: 'FitLife', rating: 4.9),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // This button now navigates to the edit screen
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROFILE HEADER ---
            _buildProfileHeader(context, userProfile),
            
            // --- PROFILE BODY (BIO, SKILLS, WORK HISTORY) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Me', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    userProfile.bio,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
                  ),
                  const Divider(height: 32),
                  
                  Text('Skills', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  // The Wrap widget handles laying out the skill chips nicely
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: userProfile.skills.map((skill) => Chip(
                      label: Text(skill),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                    )).toList(),
                  ),
                  const Divider(height: 32),
                  
                  Text('Work History & Reviews', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  // Creates a list of Card widgets from the work history data
                  ...userProfile.workHistory.map((item) => _buildWorkHistoryItem(context, item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top section of the profile page with the avatar and name.
  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profile.avatarUrl),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              profile.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${profile.averageRating} (${profile.totalReviews} Reviews)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Builds a single Card to display a past work item.
  Widget _buildWorkHistoryItem(BuildContext context, WorkHistoryItem item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(item.projectTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Client: ${item.clientName}', style: TextStyle(color: Colors.grey[600])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber[600], size: 18),
            const SizedBox(width: 4),
            Text(item.rating.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}