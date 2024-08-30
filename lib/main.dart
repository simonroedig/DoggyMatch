import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/services/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/colors.dart'; // Import your custom colors

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
