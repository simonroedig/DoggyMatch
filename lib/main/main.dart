// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/services/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/main/colors.dart'; // Import your custom colors
import 'package:doggymatch_flutter/services/auth.dart'; // Import AuthService

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AuthService _authService = AuthService(); // Instantiate AuthService

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
      _authService.updateLastOnline();
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
