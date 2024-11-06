import 'dart:developer' as dev;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img; // Import the image package
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  Future<List<Map<String, dynamic>>> fetchAllUsersWithinFilter(
      bool filterLookingForDogOwner,
      bool filterLookingForDogSitter,
      double filterDistance,
      double latitude,
      double longitude,
      int filterLastOnline) async {
    // if the filterDistance is 0.0 refetch all these parameters here from firebase
    if (filterDistance == 0.0 && latitude == 0.0 && longitude == 0.0) {
      final userProfile = await fetchUserProfile();
      if (userProfile != null) {
        filterLookingForDogOwner = userProfile.filterLookingForDogOwner;
        filterLookingForDogSitter = userProfile.filterLookingForDogSitter;
        filterDistance = userProfile.filterDistance;
        latitude = userProfile.latitude;
        longitude = userProfile.longitude;
        filterLastOnline = userProfile.filterLastOnline;
      }
    }

    // log all parameters
    dev.log('filterLookingForDogOwner: $filterLookingForDogOwner');
    dev.log('filterLookingForDogSitter: $filterLookingForDogSitter');
    dev.log('filterDistance: $filterDistance');
    dev.log('latitude: $latitude');
    dev.log('longitude: $longitude');
    dev.log('filterLastOnline: $filterLastOnline');

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

      // Calculate the timestamp for the lastOnline filter
      DateTime now = DateTime.now();
      DateTime? lastOnlineThreshold;

      switch (filterLastOnline) {
        case 2:
          lastOnlineThreshold = now.subtract(const Duration(days: 1));
          break;
        case 3:
          lastOnlineThreshold = now.subtract(const Duration(days: 3));
          break;
        case 4:
          lastOnlineThreshold = now.subtract(const Duration(days: 7));
          break;
        case 5:
          lastOnlineThreshold = now.subtract(const Duration(days: 30));
          break;
        case 1:
        default:
          lastOnlineThreshold = null; // No filtering if case 1
      }

      if (lastOnlineThreshold != null) {
        query = query.where('lastOnline',
            isGreaterThanOrEqualTo: lastOnlineThreshold.toIso8601String());
      }

      // Execute query
      QuerySnapshot querySnapshot = await query.get();

      // Filter users based on precise distance calculation
      for (var doc in querySnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        final double userLatitude = userData['latitude'].toDouble();
        final double userLongitude = userData['longitude'].toDouble();

        double distance =
            calculateDistance(latitude, longitude, userLatitude, userLongitude);

        if (distance <= filterDistance) {
          usersWithinFilter.add({
            'uid': doc.id,
            'firestoreData': userData,
            'distance': distance, // Include the distance in the user data
          });
        }
      }

      // Sort users by distance (ascending)
      usersWithinFilter.sort((a, b) => a['distance'].compareTo(b['distance']));
    } catch (e) {
      // Handle errors
      dev.log('Error fetching users within filter: $e');
    }

    return usersWithinFilter;
  }

  /////////////////////////////////////////////////////////////////////////////

  Future<String?> uploadProfileImage(String filePath, String userId) async {
    try {
      final ref = _storage.ref().child(
          'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}');

      // Read the original image file as bytes
      final File originalImageFile = File(filePath);
      final List<int> imageBytes = await originalImageFile.readAsBytes();

      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Resize and compress the image (e.g., 600px width, keeping aspect ratio)
      final img.Image resizedImage = img.copyResize(image, width: 600);

      // Encode the resized image as JPEG with a quality level (0-100, higher = better quality)
      final List<int> compressedImageBytes =
          img.encodeJpg(resizedImage, quality: 60);

      // Upload the compressed image to Firebase Storage
      final uploadTask =
          await ref.putData(Uint8List.fromList(compressedImageBytes));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      dev.log('Error uploading profile image: $e');
      return null;
    }
  }

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

  Future<void> updateLastOnline() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'lastOnline': DateTime.now().toIso8601String()});
    }
  }

  /////////////////////////////////////////////////////////////////////////////

  Future<void> updateUserProfileField(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        field: value,
      });
    }
  }

  Future<void> updateUserProfileFields(Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updates);
    }
  }

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
            lastOnline: data['lastOnline'] != null
                ? DateTime.parse(data['lastOnline'])
                : null,
            filterLastOnline: data['filterLastOnline'] ?? 3,
          );
        }
      }
    }
    return null;
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
            lastOnline: data['lastOnline'] != null
                ? DateTime.parse(data['lastOnline'])
                : null,
            filterLastOnline: data['filterLastOnline'] ?? 3,
          );
        }
      }
    } catch (e) {
      dev.log('Error fetching user profile: $e');
    }
    return null;
  }

  /////////////////////////////////////////////////////////////////////////////

  Future<void> saveUserProfile(String profileUid) async {
    // Add a user's profile UID to the current user's saved profiles
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({
        'savedProfiles': FieldValue.arrayUnion([profileUid])
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchSavedUserProfiles() async {
    final user = _auth.currentUser; // Get current user
    List<Map<String, dynamic>> savedUserProfiles = [];

    if (user != null) {
      try {
        // Get current user's document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Check if user document exists and contains saved profiles
        if (userDoc.exists) {
          final savedProfiles =
              List<String>.from(userDoc.data()?['savedProfiles'] ?? []);

          // Fetch the profiles for each saved UID
          for (String profileUid in savedProfiles) {
            final userProfile = await FirebaseFirestore.instance
                .collection('users')
                .doc(profileUid)
                .get();

            // Ensure the profile exists and add it to the savedUserProfiles list
            if (userProfile.exists) {
              savedUserProfiles.add({
                'uid': profileUid,
                'firestoreData': userProfile.data(),
              });
            }
          }

          // Optionally log the names of all saved profiles
          for (var profile in savedUserProfiles) {
            dev.log(
                'Saved profile name: ${profile['firestoreData']['userName']}');
          }
        }
      } catch (e) {
        dev.log('Error fetching saved profiles: $e');
      }
    }

    return savedUserProfiles; // Return the list of saved user profiles
  }

  Future<void> unsaveUserProfile(String profileUid) async {
    // Remove a user's profile UID from the current user's saved profiles
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({
        'savedProfiles': FieldValue.arrayRemove([profileUid])
      });
    }
  }

  Future<bool> isProfileSaved(String profileUid) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final savedProfiles =
            List<String>.from(userDoc.data()?['savedProfiles'] ?? []);
        return savedProfiles.contains(profileUid);
      }
    }
    return false;
  }
}
