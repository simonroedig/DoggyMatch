import 'dart:ui';

class UserProfile {
  final String uid;
  final String email;
  final String userName;
  final DateTime? birthday;
  final String aboutText;
  final Color profileColor;
  final List<String> images;
  final String location;
  double latitude;
  double longitude;
  final bool isDogOwner;
  final String? dogName;
  final String? dogBreed;
  final String? dogAge;
  final bool filterLookingForDogOwner;
  final bool filterLookingForDogSitter;
  final double filterDistance;

  UserProfile({
    required this.uid,
    required this.email,
    required this.userName,
    required this.birthday,
    required this.aboutText,
    required this.profileColor,
    required this.images,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.isDogOwner,
    this.dogName = '',
    this.dogBreed = '',
    this.dogAge = '',
    this.filterLookingForDogOwner = true,
    this.filterLookingForDogSitter = true,
    this.filterDistance = 10.0,
  });

  int get userAge {
    if (birthday == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthday!.year;
    if (today.month < birthday!.month ||
        (today.month == birthday!.month && today.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? userName,
    DateTime? birthday,
    String? aboutText,
    Color? profileColor,
    List<String>? images,
    String? location,
    double? latitude,
    double? longitude,
    bool? isDogOwner,
    String? dogName,
    String? dogBreed,
    String? dogAge,
    bool? filterLookingForDogOwner,
    bool? filterLookingForDogSitter,
    double? filterDistance,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      birthday: birthday ?? this.birthday,
      aboutText: aboutText ?? this.aboutText,
      profileColor: profileColor ?? this.profileColor,
      images: images ?? this.images,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDogOwner: isDogOwner ?? this.isDogOwner,
      dogName: dogName ?? this.dogName,
      dogBreed: dogBreed ?? this.dogBreed,
      dogAge: dogAge ?? this.dogAge,
      filterLookingForDogOwner:
          filterLookingForDogOwner ?? this.filterLookingForDogOwner,
      filterLookingForDogSitter:
          filterLookingForDogSitter ?? this.filterLookingForDogSitter,
      filterDistance: filterDistance ?? this.filterDistance,
    );
  }
}
