import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freelance_app/app/features/profile/user_profile_model.dart';

class ProfileService extends ChangeNotifier {
  static const _profileStorageKey = 'user_profile_data_v1';

  // ⭐ The service now creates an initial mock user WITH the avatar property
  UserProfile _userProfile = const UserProfile(name: '', title: '', bio: '', skills: [], avatarImagePath: null);

  ProfileService() {
    _loadProfile();
  }

  UserProfile get userProfile => _userProfile;

  // The save and load methods now automatically handle the new avatarImagePath
  // property because we updated the model's toJson/fromJson methods.
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileStorageKey, json.encode(_userProfile.toJson()));
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_profileStorageKey);
    if (encodedData != null) {
      _userProfile = UserProfile.fromJson(json.decode(encodedData));
    } else {
      _userProfile = _getInitialMockData();
    }
    notifyListeners();
  }

  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners();
    _saveProfile();
  }
  
  UserProfile _getInitialMockData() {
    return const UserProfile(
      name: 'Alex Doe',
      title: 'Senior Flutter Developer',
      bio: 'Creative developer proficient in Dart, GetX, and Firebase.',
      skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX'],
      avatarImagePath: null, // Initially, no avatar is set.
    );
  }
}