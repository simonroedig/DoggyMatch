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
  final DateTime? lastOnline;
  final int filterLastOnline; // 1,2,3,4,5 for Any, 1d, 3d, 1w, 1m

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
    this.lastOnline,
    this.filterLastOnline = 3,
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
    DateTime? lastOnline,
    int? filterLastOnline,
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
      lastOnline: lastOnline ?? this.lastOnline,
      filterLastOnline: filterLastOnline ?? this.filterLastOnline,
    );
  }

  // add a top map function so that assigning profile to List<Map<String, dynamic>> is possilbe
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,
      'birthday': birthday?.toIso8601String(),
      'aboutText': aboutText,
      'profileColor': profileColor.value,
      'images': images,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'isDogOwner': isDogOwner,
      'dogName': dogName,
      'dogBreed': dogBreed,
      'dogAge': dogAge,
      'filterLookingForDogOwner': filterLookingForDogOwner,
      'filterLookingForDogSitter': filterLookingForDogSitter,
      'filterDistance': filterDistance,
      'lastOnline': lastOnline?.toIso8601String(),
      'filterLastOnline': filterLastOnline,
    };
  }
}
