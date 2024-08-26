// File: main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/services/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize the UserProfile object with required parameters
  final UserProfile profile = UserProfile(
    userName: '...', // Replace with actual user data
    birthday: DateTime(1990, 1, 1), // Replace with actual birthday
    aboutText: '...', // Replace with actual about text
    profileColor: AppColors.accent1, // Replace with the actual profile color
    images: [], // Replace with actual image paths or URLs
    location: '...', // Replace with actual location
    isDogOwner: true, // Set to true or false based on user data
    dogName: '...', // Optional
    dogBreed: '...', // Optional
    dogAge: '...', // Optional
    filterLookingForDogOwner: true,
    filterLookingForDogSitter: true,
    filterDistance: 10.0,
  ); // Replace with your actual initialization logic

  runApp(MyApp(profile: profile));
}

class MyApp extends StatelessWidget {
  final UserProfile profile;

  const MyApp({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProfileState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DoggyMatch',
        home: AuthGate(profile: profile),
      ),
    );
  }
}
