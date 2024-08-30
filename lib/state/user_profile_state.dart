import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/services/auth.dart';

class UserProfileState extends ChangeNotifier {
  UserProfile? userProfile;
  bool isProfileOpen = false;
  int currentIndex = 0;

  UserProfileState() {
    _loadUserProfile(); // Load user profile during state initialization
  }

  Future<void> _loadUserProfile() async {
    userProfile = await AuthService().fetchUserProfile();
    notifyListeners();
  }

  // Method to refresh the user profile
  Future<void> refreshUserProfile() async {
    userProfile = await AuthService().fetchUserProfile();
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void openProfile() {
    isProfileOpen = true;
    notifyListeners();
  }

  void closeProfile() {
    isProfileOpen = false;
    notifyListeners();
  }

  bool isUserProfileLoaded() {
    return userProfile != null &&
        userProfile!.latitude != 0.0 &&
        userProfile!.longitude != 0.0 &&
        userProfile!.filterLookingForDogOwner != null &&
        userProfile!.filterLookingForDogSitter != null &&
        userProfile!.filterDistance != 0.0;
  }
}
