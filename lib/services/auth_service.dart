import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  Future<bool> deleteAccountAndData(context) async {
    // Delete user account, associated Firestore document, and all user images in Firebase Storage
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDocSnapshot = await userDocRef.get();

        if (userDocSnapshot.exists) {
          final userData = userDocSnapshot.data();
          if (userData != null) {
            // Delete all user images from Firebase Storage
            List<String> images = List<String>.from(userData['images'] ?? []);
            for (String imageUrl in images) {
              await _profileService.deleteProfileImage(imageUrl);
            }
          }
        }

        // Delete the user's document from Firestore
        await userDocRef.delete();

        // Delete the user's Firebase account
        await user.delete();
        // added the next 4 lines recentyl without testing
        await FirebaseFirestore.instance.terminate(); // Clear Firestore cache
        await FirebaseFirestore.instance.clearPersistence();
        Provider.of<UserProfileState>(context, listen: false).clearProfile();
        return true;
      }
    } catch (e) {
      dev.log('Error deleting account and data: $e');
    }
    return false;
  }

  String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  String? getCurrentUserEmail() {
    final user = _auth.currentUser;
    return user?.email;
  }

  Future createUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future createUserDocument(UserCredential userCredential) async {
    if (userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'uid': userCredential.user!.uid,
      });
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      dev.log('userCredential: $userCredential');
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future signOut(context) async {
    try {
      await FirebaseFirestore.instance.terminate(); // Clear Firestore cache
      await FirebaseFirestore.instance.clearPersistence();
      Provider.of<UserProfileState>(context, listen: false).clearProfile();
      FirebaseAuth.instance.signOut();
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
