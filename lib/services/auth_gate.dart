// File: auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/pages/main_screen.dart';
import 'package:doggymatch_flutter/pages/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has data, meaning the user is authenticated, go to MainScreen
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const WelcomePage();
          } else {
            // Refresh user profile when user logs in
            final userProfileState =
                Provider.of<UserProfileState>(context, listen: false);
            userProfileState.refreshUserProfile();

            return MainScreen();
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
}
