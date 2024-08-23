import 'dart:ui';

abstract class Profile {
  final String userName;
  final int userAge;
  final String aboutText;
  final Color profileColor;
  final List<String> images; // Add this line

  Profile({
    required this.userName,
    required this.userAge,
    required this.aboutText,
    required this.profileColor,
    required this.images, // Add this line
  });
}

class DogSitterProfile extends Profile {
  DogSitterProfile({
    required super.userName,
    required super.userAge,
    required super.aboutText,
    required super.profileColor,
    required super.images, // Add this line
  });
}

class DogOwnerProfile extends Profile {
  final String dogName;
  final String dogBreed;
  final int dogAge;

  DogOwnerProfile({
    required super.userName,
    required super.userAge,
    required super.aboutText,
    required super.profileColor,
    required super.images, // Add this line
    required this.dogName,
    required this.dogBreed,
    required this.dogAge,
  });
}
