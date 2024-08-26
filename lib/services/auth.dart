import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // https://www.youtube.com/watch?v=Xe-8igE1_JI
  // testpassword

  // Delete user account and associated Firestore document
  // auth.dart

  // Delete user account, associated Firestore document, and all user images in Firebase Storage
  Future<bool> deleteAccountAndData() async {
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
              await deleteProfileImage(imageUrl);
            }
          }
        }

        // Delete the user's document from Firestore
        await userDocRef.delete();

        // Delete the user's Firebase account
        await user.delete();
        return true;
      }
    } catch (e) {
      print('Error deleting account and data: $e');
    }
    return false;
  }

  // Get the current user's UID
  String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  // Upload image to Firebase Storage
  Future<String?> uploadProfileImage(String filePath, String userId) async {
    try {
      final ref = _storage.ref().child(
          'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await ref.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Handle errors here
    }
  }

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
  Future<UserProfile?> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          return UserProfile(
            userName: data['userName'] ?? '',
            birthday: data['birthday'] != null
                ? DateTime.parse(data['birthday'])
                : null,
            aboutText: data['aboutText'] ?? '',
            profileColor: Color(data['profileColor'] ?? 0xFFFFFFFF),
            images: List<String>.from(data['images'] ?? []),
            location: data['location'] ?? '',
            isDogOwner: data['isDogOwner'] ?? false,
            dogName: data['dogName'] ?? '',
            dogBreed: data['dogBreed'] ?? '',
            dogAge: data['dogAge'] ?? '',
            filterLookingForDogOwner: data['filterLookingForDogOwner'] ?? true,
            filterLookingForDogSitter:
                data['filterLookingForDogSitter'] ?? true,
            filterDistance: (data['filterDistance'] ?? 10.0).toDouble(),
          );
        }
      }
    }
    return null;
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
