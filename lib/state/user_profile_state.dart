import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';

class UserProfileState extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(
    userName: 'Sara',
    birthday: DateTime(1994, 7, 14),
    aboutText: 'I love my dog and am looking for a trustworthy sitter.',
    profileColor: AppColors.accent1,
    images: ['assets/icons/zz.png', 'assets/icons/zz.png'],
    location: 'Munich',
    distance: '5.2 km',
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

  void updateDogOwnerStatus(bool isDogOwner) {
    _userProfile = _userProfile.copyWith(isDogOwner: isDogOwner);
    notifyListeners();
  }

  void updateProfileColor(Color color) {
    _userProfile = _userProfile.copyWith(profileColor: color);
    notifyListeners();
  }

  void updateUserProfileImages(List<String> images) {
    _userProfile = _userProfile.copyWith(images: images);
    notifyListeners();
  }

  void updateUserProfile({
    required String name,
    required DateTime? birthday,
    required String location,
    required String aboutText,
    String? dogName,
    String? dogBreed,
    String? dogAge,
  }) {
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
  }

  void updateFilterSettings({
    required bool filterLookingForDogOwner,
    required bool filterLookingForDogSitter,
    required double filterDistance,
  }) {
    _userProfile = _userProfile.copyWith(
      filterLookingForDogOwner: filterLookingForDogOwner,
      filterLookingForDogSitter: filterLookingForDogSitter,
      filterDistance: filterDistance,
    );
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
