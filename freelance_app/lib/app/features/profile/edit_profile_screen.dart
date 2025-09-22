import 'package:flutter/material.dart';

// This is the class that was missing.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We can add state later, for now, this is a stateless UI representation.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        // Add a save button to the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: 'Save Changes',
            onPressed: () {
              // In a real app, this would process a form.
              // For now, show a confirmation and go back.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile changes saved!")),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Use a Form for better validation and data handling in the future
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pre-filled with static data for demonstration
              TextFormField(
                initialValue: "Jane Doe",
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: "Senior Flutter Developer & UI Designer",
                decoration: const InputDecoration(
                  labelText: "Title / Role",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: "Creative and detail-oriented developer...",
                decoration: const InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Good for multiline fields
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: "Flutter, UI Design, Firebase, State Management",
                decoration: const InputDecoration(
                  labelText: "Skills (comma separated)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // This button can do the same as the save icon in the app bar.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile changes saved!")),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}