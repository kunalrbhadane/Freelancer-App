import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String name;
  final String title;
  final String bio;
  final List<String> skills;
  // ⭐ The new property to store the permanent path to the saved image file.
  // It is nullable because a user may not have an avatar set.
  final String? avatarImagePath;

  const UserProfile({
    required this.name,
    required this.title,
    required this.bio,
    required this.skills,
    this.avatarImagePath, // Add to constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'bio': bio,
      'skills': skills,
      'avatarImagePath': avatarImagePath, // Add to JSON
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      title: json['title'],
      bio: json['bio'],
      skills: List<String>.from(json['skills']),
      avatarImagePath: json['avatarImagePath'], // Read from JSON
    );
  }
}