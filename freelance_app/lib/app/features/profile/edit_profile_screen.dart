import 'package:flutter/material.dart';
import 'package:freelance_app/app/features/profile/profile_service.dart';
import 'package:freelance_app/app/features/profile/user_profile_model.dart';
import 'package:provider/provider.dart';

/// A form screen that allows the user to edit their profile information.
///
/// It pre-fills its fields with the current data from [ProfileService] and
/// calls the service's update method upon successful form submission.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    // Get the current profile data from the service to pre-fill the form.
    // We use listen: false because this only needs to happen once when the screen is created.
    final profile = Provider.of<ProfileService>(context, listen: false).userProfile;

    // Initialize controllers with the existing data.
    _nameController = TextEditingController(text: profile.name);
    _titleController = TextEditingController(text: profile.title);
    _bioController = TextEditingController(text: profile.bio);
    // Convert the list of skills back into a comma-separated string for the text field.
    _skillsController = TextEditingController(text: profile.skills.join(', '));
  }

  @override
  void dispose() {
    // Always dispose of controllers to prevent memory leaks.
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  /// Handles form validation and submission.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final profileService = Provider.of<ProfileService>(context, listen: false);

      // Split the skills string into a list, trimming whitespace from each skill.
      final skillsList = _skillsController.text.split(',').map((s) => s.trim()).toList();

      // Create a new UserProfile object from the form's data.
      final updatedProfile = UserProfile(
        name: _nameController.text,
        title: _titleController.text,
        bio: _bioController.text,
        skills: skillsList,
      );

      // Call the service method to update the app's state.
      profileService.updateUserProfile(updatedProfile);

      // Return to the profile screen.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter your name.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title / Role (e.g., Senior Developer)'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter your title.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio', alignLabelWithHint: true),
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? 'Please enter a bio.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(labelText: 'Skills (comma-separated)', hintText: 'e.g., Flutter, Dart, Firebase'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter at least one skill.' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _submitForm, child: const Text('Save Changes')),
            ],
          ),
        ),
      ),
    );
  }
}