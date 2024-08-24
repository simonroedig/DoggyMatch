import 'dart:ui';

class UserProfile {
  final String userName;
  final DateTime userBirthday;
  final String aboutText;
  final Color profileColor;
  final List<String> images;
  final String location;
  final String distance;
  final bool isDogOwner;
  final String? dogName;
  final String? dogBreed;
  final int? dogAge;

  UserProfile({
    required this.userName,
    required this.userBirthday,
    required this.aboutText,
    required this.profileColor,
    required this.images,
    required this.location,
    required this.distance,
    required this.isDogOwner,
    this.dogName,
    this.dogBreed,
    this.dogAge,
  });

  // Method to calculate the user's age based on their birthday
  int get userAge {
    final now = DateTime.now();
    int age = now.year - userBirthday.year;
    if (now.month < userBirthday.month ||
        (now.month == userBirthday.month && now.day < userBirthday.day)) {
      age--;
    }
    return age;
  }

  UserProfile copyWith({
    String? userName,
    DateTime? userBirthday,
    String? aboutText,
    Color? profileColor,
    List<String>? images,
    String? location,
    String? distance,
    bool? isDogOwner,
    String? dogName,
    String? dogBreed,
    int? dogAge,
  }) {
    return UserProfile(
      userName: userName ?? this.userName,
      userBirthday: userBirthday ?? this.userBirthday,
      aboutText: aboutText ?? this.aboutText,
      profileColor: profileColor ?? this.profileColor,
      images: images ?? this.images,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      isDogOwner: isDogOwner ?? this.isDogOwner,
      dogName: dogName ?? this.dogName,
      dogBreed: dogBreed ?? this.dogBreed,
      dogAge: dogAge ?? this.dogAge,
    );
  }
}
