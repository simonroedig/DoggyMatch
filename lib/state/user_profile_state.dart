import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';

class UserProfileState extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(
    userName: 'Sara',
    userAge: 30,
    aboutText: 'I love my dog and am looking for a trustworthy sitter.',
    profileColor: AppColors.accent1,
    images: ['assets/icons/zz.png', 'assets/icons/zz.png'],
    location: 'Munich',
    distance: '5.2 km',
    isDogOwner: true,
    dogName: 'Buddy',
    dogBreed: 'Golden Retriever',
    dogAge: 5,
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

  void updateUserProfile({
    required String name,
    required int age,
    required String location,
    required String aboutText,
    String? dogName,
    String? dogBreed,
    int? dogAge,
  }) {
    _userProfile = _userProfile.copyWith(
      userName: name,
      userAge: age,
      location: location,
      aboutText: aboutText,
      dogName: dogName,
      dogBreed: dogBreed,
      dogAge: dogAge,
    );
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
