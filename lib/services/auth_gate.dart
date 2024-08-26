// File: auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/pages/main_screen.dart';
import 'package:doggymatch_flutter/pages/welcome_page.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class AuthGate extends StatelessWidget {
  final UserProfile profile;

  const AuthGate({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has data, meaning the user is authenticated, go to MainScreen
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            _openWelcomePage(context);
          } else {
            return const MainScreen();
          }
        }

        // Otherwise, show a loading spinner while waiting for the auth state to load
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _openWelcomePage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WelcomePage(
            profile: profile,
          ),
        ),
      );
    });
  }
}
