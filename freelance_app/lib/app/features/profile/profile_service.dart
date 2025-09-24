import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freelance_app/app/features/profile/user_profile_model.dart';

/// The central state management service for the user's profile data.
/// This class handles loading data from storage, modifying it in memory, and
/// instantly saving every change back to storage.
class ProfileService extends ChangeNotifier {
  // The unique key for storing the user profile JSON string in SharedPreferences.
  static const _profileStorageKey = 'user_profile_data_v1';

  // The in-memory user profile. It starts empty and is populated by _loadProfile.
  // Using a default empty profile prevents null errors during the initial load.
  UserProfile _userProfile = const UserProfile(name: '', title: '', bio: '', skills: []);

  ProfileService() {
    // When the service is created at app startup, immediately load the saved profile.
    _loadProfile();
  }

  /// Provides safe, read-only access to the current user profile.
  UserProfile get userProfile => _userProfile;

  // --- Persistence Methods ---

  /// Asynchronously saves the current `_userProfile` to the device's local storage.
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the UserProfile object into a JSON string.
    final String encodedData = json.encode(_userProfile.toJson());
    // Save the string to storage with our unique key.
    await prefs.setString(_profileStorageKey, encodedData);
  }

  /// Asynchronously loads the user profile from local storage.
  /// If no data exists, it loads initial mock data.
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_profileStorageKey);

    if (encodedData != null && encodedData.isNotEmpty) {
      // If data exists, decode the JSON string and create a UserProfile object from it.
      _userProfile = UserProfile.fromJson(json.decode(encodedData));
    } else {
      // ⭐ STAR SERVICE: THIS IS THE CORRECTED LINE
      // If no data is found (first app launch), populate with the default mock profile.
      _userProfile = _getInitialMockData();
    }
    // Notify all listening UI widgets (like the ProfileScreen) that the data is ready.
    notifyListeners();
  }

  // --- Public Method (The API for the UI to interact with) ---

  /// Updates the in-memory profile, notifies listeners, and then saves the changes.
  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners();
    _saveProfile();
  }
  
  // --- Initial Data ---

  /// Provides a default user profile for the very first app launch.
  UserProfile _getInitialMockData() {
    return const UserProfile(
      name: 'Alex Doe',
      title: 'Senior Flutter Developer',
      bio: 'Creative and detail-oriented Flutter developer with over 5 years of experience in mobile application design. Proficient in Dart, GetX, and Firebase.',
      skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'GetX State Management'],
    );
  }
}