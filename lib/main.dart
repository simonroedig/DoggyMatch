import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/services/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/notifiers/filter_notifier.dart'; // Import FilterNotifier

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileState()),
        ChangeNotifierProvider(
            create: (_) => FilterNotifier()), // Add FilterNotifier
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DoggyMatch',
        theme: ThemeData(
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.customBlack,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
