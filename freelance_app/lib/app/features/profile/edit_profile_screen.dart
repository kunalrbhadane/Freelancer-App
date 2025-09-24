import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:freelance_app/app/features/profile/profile_service.dart';
import 'package:freelance_app/app/features/profile/user_profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- STATE AND CONTROLLERS (No changes needed in this section) ---
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileService>(context, listen: false).userProfile;
    _nameController = TextEditingController(text: profile.name);
    _titleController = TextEditingController(text: profile.title);
    _bioController = TextEditingController(text: profile.bio);
    _skillsController = TextEditingController(text: profile.skills.join(', '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
  
  // --- LOGIC METHODS (No changes needed in this section) ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedXFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedXFile != null) {
      setState(() { _pickedImageFile = File(pickedXFile.path); });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final profileService = Provider.of<ProfileService>(context, listen: false);
      String? savedImagePath = profileService.userProfile.avatarImagePath;

      if (_pickedImageFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(_pickedImageFile!.path);
        final savedImage = await _pickedImageFile!.copy('${appDir.path}/$fileName');
        savedImagePath = savedImage.path;
      }

      final skillsList = _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final updatedProfile = UserProfile(
        name: _nameController.text,
        title: _titleController.text,
        bio: _bioController.text,
        skills: skillsList,
        avatarImagePath: savedImagePath,
      );
      
      profileService.updateUserProfile(updatedProfile);
      if (mounted) Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final existingImagePath = context.watch<ProfileService>().userProfile.avatarImagePath;

    // ⭐ STAR SERVICE: The entire UI structure is rebuilt with a focus on clarity and professionalism.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        // We use a Column with some padding for the main layout.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildAvatarPicker(existingImagePath),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- This is the new, improved TextField style ---
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icons.person_outline,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter your name.' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration(
                        labelText: 'Title / Role',
                        hintText: 'e.g., Senior Developer',
                        prefixIcon: Icons.work_outline,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter your title.' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      decoration: _buildInputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icons.description_outlined,
                      ),
                      maxLines: 5,
                      validator: (v) => v == null || v.isEmpty ? 'Please enter a bio.' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _skillsController,
                      decoration: _buildInputDecoration(
                        labelText: 'Skills',
                        hintText: 'e.g., Flutter, Dart, Firebase',
                        prefixIcon: Icons.lightbulb_outline,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter at least one skill.' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // The main action button remains the same, as it was already well-designed.
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 20), // Extra space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW UI HELPER WIDGETS ---

  /// ⭐ STAR SERVICE: A new helper method that creates a consistent and professional
  /// InputDecoration for all text fields.
  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
  }) {
    // Note: In a large app, this styling would be defined once in the main AppTheme
    // in main.dart for app-wide consistency. Defining it here is clear for this specific screen.
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      // Gives the text field a background color.
      filled: true,
      // Creates a nice, modern rounded border.
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      // Defines the border style when the field is NOT focused.
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      // Defines the border style when the user taps into the field.
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
    );
  }

  /// Helper widget for the dynamic avatar picker. This remains the same as it was well-designed.
  Widget _buildAvatarPicker(String? existingImagePath) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // 10% opacity
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                backgroundImage: _pickedImageFile != null
                    ? FileImage(_pickedImageFile!)
                    : (existingImagePath != null
                        ? FileImage(File(existingImagePath))
                        : null) as ImageProvider?,
                child: (_pickedImageFile == null && existingImagePath == null)
                    ? Icon(Icons.person, size: 70, color: Colors.grey.shade400)
                    : null,
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 5, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}