import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';

class UserProfileState extends ChangeNotifier {
  final _authProfile = ProfileService();

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
    listenToAuthState();
  }

  void listenToAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User signed out
        clearProfile();
      } else {
        // User signed in
        _initializeUserProfile();
      }
    });
  }

  void clearProfile() {
    // Reset user profile to default values
    _userProfile = UserProfile(
      uid: '',
      email: '',
      userName: '',
      birthday: DateTime(2000, 1, 1),
      aboutText: '',
      profileColor: AppColors.accent1,
      images: [UserProfileState.placeholderImageUrl],
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
      filterLastOnline: 3,
    );

    // Reset other state variables
    _currentIndex = 0;
    _isProfileOpen = false;

    // Notify listeners to rebuild UI
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
    await _authProfile.updateUserProfileField('images', images);
  }

  Future<void> _initializeUserProfile() async {
    UserProfile? fetchedProfile = await _authProfile.fetchUserProfile();
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
    await _authProfile.updateUserProfileField('isDogOwner', isDogOwner);
  }

  Future<void> updateProfileColor(Color color) async {
    _userProfile = _userProfile.copyWith(profileColor: color);
    notifyListeners();
    await _authProfile.updateUserProfileField('profileColor', color.value);
  }

  Future<void> updateUserProfileFromEdit({
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
    // Update local state
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

    // Build a map of fields to update
    final Map<String, dynamic> updates = {
      'userName': name,
      'birthday': birthday?.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'aboutText': aboutText,
      if (dogName != null) 'dogName': dogName,
      if (dogBreed != null) 'dogBreed': dogBreed,
      if (dogAge != null) 'dogAge': dogAge,
    };

    await _authProfile.updateUserProfileFields(updates);
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

    final Map<String, dynamic> updates = {
      'filterLookingForDogOwner': filterLookingForDogOwner,
      'filterLookingForDogSitter': filterLookingForDogSitter,
      'filterDistance': filterDistance,
      'filterLastOnline': filterLastOnline,
    };

    await _authProfile.updateUserProfileFields(updates);
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
