import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/services/auth.dart';

class UserProfileState extends ChangeNotifier {
  final _auth = AuthService();

  static const String placeholderImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/doggymatch-bb17f.appspot.com/o/placeholder.png?alt=media&token=b02e0072-f0f9-45dc-8db6-517fe82491b1';

  UserProfile _userProfile = UserProfile(
    userName: 'Sara',
    birthday: DateTime(1994, 7, 14),
    aboutText: 'I love my dog and am looking for a trustworthy sitter.',
    profileColor: AppColors.accent1,
    images: [],
    location: 'Munich',
    isDogOwner: true,
    dogName: 'Buddy',
    dogBreed: 'Golden Retriever',
    dogAge: 'ca. 4',
    filterLookingForDogOwner: true,
    filterLookingForDogSitter: true,
    filterDistance: 5.0,
  );

  int _currentIndex = 0;

  UserProfile get userProfile => _userProfile;
  int get currentIndex => _currentIndex;

  UserProfileState() {
    _initializeUserProfile();
  }

  List<String> get userImages {
    return _userProfile.images
        .where((image) => image != placeholderImageUrl)
        .toList();
  }

  Future<void> updateUserProfileImages(List<String> images) async {
    // Exclude the placeholder image from updates
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
    } else {
      _userProfile = _userProfile.copyWith(images: [placeholderImageUrl]);
      notifyListeners();
    }
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
    required String aboutText,
    String? dogName,
    String? dogBreed,
    String? dogAge,
  }) async {
    _userProfile = _userProfile.copyWith(
      userName: name,
      birthday: birthday,
      location: location,
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
  }) async {
    _userProfile = _userProfile.copyWith(
      filterLookingForDogOwner: filterLookingForDogOwner,
      filterLookingForDogSitter: filterLookingForDogSitter,
      filterDistance: filterDistance,
    );
    notifyListeners();
    await _auth.addUserProfileData(_userProfile);
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
