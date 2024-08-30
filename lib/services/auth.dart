import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
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

  // Fetch all users and their respective Firestore documents
  Future<List<Map<String, dynamic>>> fetchAllUsersWithDocuments() async {
    List<Map<String, dynamic>> usersWithDocuments = [];

    try {
      // Fetch all user documents from Firestore
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Iterate over each user document
      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final uid = userDoc.id;

        // Add the user's Firestore data along with the UID to the list
        usersWithDocuments.add({
          'uid': uid,
          'firestoreData': userData,
        });
      }
    } catch (e) {
      dev.log('Error fetching users and documents: $e');
    }

    return usersWithDocuments;
  }

  // fetch all users within filter (certrain distance, looking for dog owner/sitter)
  Future<List<Map<String, dynamic>>> fetchAllUsersWithinFilter(
      bool filterLookingForDogOwner,
      bool filterLookingForDogSitter,
      double filterDistance,
      double latitude,
      double longitude) async {
    // log all parameters
    dev.log('filterLookingForDogOwner: $filterLookingForDogOwner');
    dev.log('filterLookingForDogSitter: $filterLookingForDogSitter');
    dev.log('filterDistance: $filterDistance');
    dev.log('latitude: $latitude');
    dev.log('longitude: $longitude');

    List<Map<String, dynamic>> usersWithinFilter = [];
    try {
      // Constants for Earth's radius in km
      const double earthRadius = 6371.0;

      // Calculate bounding box
      double latDelta = filterDistance / earthRadius;
      double lonDelta =
          filterDistance / (earthRadius * cos(pi * latitude / 180.0));

      double minLat = latitude - latDelta * 180.0 / pi;
      double maxLat = latitude + latDelta * 180.0 / pi;
      double minLon = longitude - lonDelta * 180.0 / pi;
      double maxLon = longitude + lonDelta * 180.0 / pi;

      // Build query
      Query query = FirebaseFirestore.instance
          .collection('users')
          .where('latitude', isGreaterThanOrEqualTo: minLat)
          .where('latitude', isLessThanOrEqualTo: maxLat)
          .where('longitude', isGreaterThanOrEqualTo: minLon)
          .where('longitude', isLessThanOrEqualTo: maxLon);

      // Apply additional filters
      if (filterLookingForDogOwner && !filterLookingForDogSitter) {
        query = query.where('isDogOwner', isEqualTo: true);
      }
      if (filterLookingForDogSitter && !filterLookingForDogOwner) {
        query = query.where('isDogOwner', isEqualTo: false);
      }
      // looking for both
      if (filterLookingForDogOwner && filterLookingForDogSitter) {}

      // Execute query
      QuerySnapshot querySnapshot = await query.get();

      // Filter users based on precise distance calculation
      for (var doc in querySnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        final double userLatitude = userData['latitude'].toDouble();
        final double userLongitude = userData['longitude'].toDouble();

        double distance = _calculateDistance(
            latitude, longitude, userLatitude, userLongitude);

        if (distance <= filterDistance) {
          usersWithinFilter.add({
            'uid': doc.id,
            'firestoreData': userData,
          });
        }
      }
    } catch (e) {
      // Handle errors
      dev.log('Error fetching users within filter: $e');
    }

    return usersWithinFilter;
  }

  Future<UserProfile?> fetchOtherUserProfile(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          //dev.log the user email and username
          dev.log('User email: ${data['email']}');
          dev.log('User name: ${data['userName']}');
          return UserProfile(
            uid: uid,
            email: data['email'] ?? '',
            userName: data['userName'] ?? '',
            birthday: data['birthday'] != null
                ? DateTime.parse(data['birthday'])
                : null,
            aboutText: data['aboutText'] ?? '',
            profileColor: Color(data['profileColor'] ?? 0xFFFFFFFF),
            images: List<String>.from(data['images'] ?? []),
            location: data['location'] ?? '',
            latitude: (data['latitude'] ?? 0.0).toDouble(),
            longitude: (data['longitude'] ?? 0.0).toDouble(),
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
    } catch (e) {
      dev.log('Error fetching user profile: $e');
    }
    return null;
  }

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
      dev.log('Error deleting account and data: $e');
    }
    return false;
  }

  // Get the current user's UID
  String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  // Get the current user's email
  String? getCurrentUserEmail() {
    final user = _auth.currentUser;
    return user?.email;
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
      if (imageUrl.contains("placeholder")) {
        return;
      }
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
        'latitude': userProfile.latitude,
        'longitude': userProfile.longitude,
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
            uid: user.uid,
            email: user.email!,
            userName: data['userName'] ?? '',
            birthday: data['birthday'] != null
                ? DateTime.parse(data['birthday'])
                : null,
            aboutText: data['aboutText'] ?? '',
            profileColor: Color(data['profileColor'] ?? 0xFFFFFFFF),
            images: List<String>.from(data['images'] ?? []),
            location: data['location'] ?? '',
            latitude: (data['latitude'] ?? 0.0).toDouble(),
            longitude: (data['longitude'] ?? 0.0).toDouble(),
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
      await FirebaseFirestore.instance.terminate(); // Clear Firestore cache
      await FirebaseFirestore.instance.clearPersistence();

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

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
