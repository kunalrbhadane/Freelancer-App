import 'package:flutter/foundation.dart';
import 'package:freelance_app/app/features/profile/user_profile_model.dart';

/// The central state management service for the user's profile data.
///
/// This service holds the profile information and provides a method to update it.
/// It uses [ChangeNotifier] to alert listening widgets to rebuild when the
/// profile data is changed.
class ProfileService extends ChangeNotifier {
  // The private, internal state for the profile, initialized with mock data.
  UserProfile _userProfile = const UserProfile(
    name: 'Alex Doe',
    title: 'Senior Flutter Developer',
    bio: 'Creative and detail-oriented Flutter developer with over 5 years of experience in mobile application design. Proficient in Dart, GetX, and Firebase.',
    skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'GetX State Management'],
  );

  /// Provides safe, read-only access to the current user profile.
  UserProfile get userProfile => _userProfile;

  /// Updates the user's profile and notifies all listening widgets of the change.
  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners(); // This is the magic line that triggers the UI update.
  }
}