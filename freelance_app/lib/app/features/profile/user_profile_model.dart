import 'package:flutter/foundation.dart';

/// Represents all the data for a single user's profile.
///
/// Using [immutable] annotation ensures that the object's properties cannot
/// be changed after creation, promoting a safer state management pattern where
/// the entire object is replaced on update.
@immutable
class UserProfile {
  final String name;
  final String title;
  final String bio;
  final List<String> skills;
  // In a real app, these would also be editable:
  // final String avatarUrl;
  // final double averageRating;
  // final int totalReviews;

  const UserProfile({
    required this.name,
    required this.title,
    required this.bio,
    required this.skills,
  });
}