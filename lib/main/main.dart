// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/services/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/main/colors.dart'; // Import your custom colors
import 'package:doggymatch_flutter/services/profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options for web if on web platform
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBhphtWt7ClCnvKQawOSdRG4pFyrt8E3qo",
          authDomain: "doggymatch-bb17f.firebaseapp.com",
          projectId: "doggymatch-bb17f",
          storageBucket: "doggymatch-bb17f.appspot.com",
          messagingSenderId: "193586085616",
          appId: "1:193586085616:web:122ae30fb65d415a738c35",
          measurementId: "G-77YE3J8R26"),
    );
  } else {
    // Default initialization for other platforms
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _authProfile = ProfileService();

  @override
  void initState() {
    super.initState();
    // Add this widget to observe the app lifecycle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove this widget from the lifecycle observation
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App is either minimized or closed
      _authProfile.updateLastOnline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProfileState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DoggyMatch',
        theme: ThemeData(
          // Set the global progress indicator theme with your custom color
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.customBlack,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
