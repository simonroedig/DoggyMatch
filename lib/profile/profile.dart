import 'dart:ui';

class UserProfile {
  final String userName;
  final int userAge;
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
    required this.userAge,
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

  UserProfile copyWith({
    String? userName,
    int? userAge,
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
      userAge: userAge ?? this.userAge,
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
