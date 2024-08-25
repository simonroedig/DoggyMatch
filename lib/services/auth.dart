import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // https://www.youtube.com/watch?v=Xe-8igE1_JI
  // testpassword

  // create user with email and password
  Future createUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } catch (e) {
      return null;
    }
  }

  // create user document
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

  // add data to user document
  Future<void> addUserProfileData(UserProfile userProfile) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userProfileData = {
        'userName': userProfile.userName,
        'birthday': userProfile.birthday
            ?.toIso8601String(), // Store date as ISO8601 string
        'aboutText': userProfile.aboutText,
        'profileColor':
            userProfile.profileColor.value, // Convert Color to integer
        'images': userProfile.images,
        'location': userProfile.location,
        'isDogOwner': userProfile.isDogOwner,
        'dogName': userProfile.dogName,
        'dogBreed': userProfile.dogBreed,
        'dogAge': userProfile.dogAge,
        'filterLookingForDogOwner': userProfile.filterLookingForDogOwner,
        'filterLookingForDogSitter': userProfile.filterLookingForDogSitter,
        'filterDistance': userProfile.filterDistance,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(userProfileData);
    }
  }

  // get current user document
  Future getCurrentUserDocument() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    }
  }

  // sign in user with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  // Delete user account
  Future deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
