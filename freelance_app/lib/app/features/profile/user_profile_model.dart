import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String name;
  final String title;
  final String bio;
  final List<String> skills;

  const UserProfile({
    required this.name,
    required this.title,
    required this.bio,
    required this.skills,
  });

  // ⭐ STAR SERVICE: NEW SERIALIZATION LOGIC STARTS HERE

  /// Converts this UserProfile object into a Map for JSON storage.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'bio': bio,
      'skills': skills, // Lists of simple types are directly storable.
    };
  }

  /// Creates a UserProfile object from a Map (decoded from JSON).
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      title: json['title'],
      bio: json['bio'],
      // We cast the result from List<dynamic> to List<String> for type safety.
      skills: List<String>.from(json['skills']),
    );
  }
}