import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/services/auth.dart';

class UserProfileState extends ChangeNotifier {
  final _auth = AuthService();

  static const String placeholderImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/doggymatch-bb17f.appspot.com/o/placeholder.png?alt=media&token=6c364b4d-0e8b-4b34-b29e-58dc6dadcc65';

  UserProfile _userProfile = UserProfile(
      uid: '',
      email: '',
      userName: '',
      birthday: DateTime(2000, 1, 1),
      aboutText: '',
      profileColor: AppColors.accent1,
      images: [placeholderImageUrl],
      location: '',
      latitude: 0.0,
      longitude: 0.0,
      isDogOwner: false,
      dogName: '',
      dogBreed: '',
      dogAge: '',
      filterLookingForDogOwner: false,
      filterLookingForDogSitter: false,
      filterDistance: 0.0,
      lastOnline: DateTime.now(),
      filterLastOnline: 3);

  int _currentIndex = 0;
  bool _isProfileOpen = false;

  UserProfile get userProfile => _userProfile;
  int get currentIndex => _currentIndex;
  bool get isProfileOpen => _isProfileOpen;

  UserProfileState() {
    _initializeUserProfile();
  }

  // Reset state method
  void resetState() {
    _userProfile = UserProfile(
        uid: '',
        email: '',
        userName: '',
        birthday: DateTime(2000, 1, 1),
        aboutText: '',
        profileColor: AppColors.accent1,
        images: [placeholderImageUrl],
        location: '',
        latitude: 0.0,
        longitude: 0.0,
        isDogOwner: false,
        dogName: '',
        dogBreed: '',
        dogAge: '',
        filterLookingForDogOwner: false,
        filterLookingForDogSitter: false,
        filterDistance: 0.0,
        lastOnline: DateTime.now(),
        filterLastOnline: 3);
    _currentIndex = 0;
    _isProfileOpen = false;
    notifyListeners();
  }

  List<String> get userImages {
    return _userProfile.images
        .where((image) => image != placeholderImageUrl)
        .toList();
  }

  Future<void> updateUserProfileImages(List<String> images) async {
    _userProfile = _userProfile.copyWith(
      images: images.isEmpty ? [placeholderImageUrl] : images,
    );
    notifyListeners();
    await _auth.addUserProfileData(_userProfile);
  }

  Future<void> _initializeUserProfile() async {
    UserProfile? fetchedProfile = await _auth.fetchUserProfile();
    if (fetchedProfile != null) {
      if (fetchedProfile.images.isEmpty) {
        fetchedProfile = fetchedProfile.copyWith(images: [placeholderImageUrl]);
      }
      _userProfile = fetchedProfile;
      notifyListeners();
    }
  }

  Future<void> refreshUserProfile() async {
    await _initializeUserProfile();
  }

  Future<void> updateDogOwnerStatus(bool isDogOwner) async {
    _userProfile = _userProfile.copyWith(isDogOwner: isDogOwner);
    notifyListeners();
    await _auth.addUserProfileData(_userProfile);
  }

  Future<void> updateProfileColor(Color color) async {
    _userProfile = _userProfile.copyWith(profileColor: color);
    notifyListeners();
    await _auth.addUserProfileData(_userProfile);
  }

  Future<void> updateUserProfile({
    required String name,
    required DateTime? birthday,
    required String location,
    required double latitude,
    required double longitude,
    required String aboutText,
    String? dogName,
    String? dogBreed,
    String? dogAge,
  }) async {
    _userProfile = _userProfile.copyWith(
      userName: name,
      birthday: birthday,
      location: location,
      latitude: latitude,
      longitude: longitude,
      aboutText: aboutText,
      dogName: dogName,
      dogBreed: dogBreed,
      dogAge: dogAge,
    );
    notifyListeners();
    await _auth.addUserProfileData(_userProfile);
  }

  Future<void> updateFilterSettings({
    required bool filterLookingForDogOwner,
    required bool filterLookingForDogSitter,
    required double filterDistance,
    required int filterLastOnline,
  }) async {
    _userProfile = _userProfile.copyWith(
      filterLookingForDogOwner: filterLookingForDogOwner,
      filterLookingForDogSitter: filterLookingForDogSitter,
      filterDistance: filterDistance,
      filterLastOnline: filterLastOnline,
    );
    notifyListeners();
    await _auth.addUserProfileData(_userProfile);
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void openProfile() {
    log('Open profile via profile state');
    _isProfileOpen = true;
    notifyListeners();
  }

  void closeProfile() {
    _isProfileOpen = false;
    log('Close profile via profile state');
    notifyListeners();
  }
}
