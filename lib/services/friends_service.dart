import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

class FriendsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendFriendRequest(String profileUid) async {
    // Add a user's profile UID to the current user's saved profiles
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({
        'outgoingFriendRequests': FieldValue.arrayUnion([profileUid])
      });
    }
    // update other persons incomingFriendRequests
    final profileDocRef =
        FirebaseFirestore.instance.collection('users').doc(profileUid);
    await profileDocRef.update({
      'incomingFriendRequests': FieldValue.arrayUnion([user!.uid])
    });
  }

  Future<void> cancelFriendRequest(String profileUid) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({
        'outgoingFriendRequests': FieldValue.arrayRemove([profileUid])
      });
    }
    // update other persons incomingFriendRequests
    final profileDocRef =
        FirebaseFirestore.instance.collection('users').doc(profileUid);
    await profileDocRef.update({
      'incomingFriendRequests': FieldValue.arrayRemove([user!.uid])
    });
  }

  Future<bool> isFriendRequestSent(String profileUid) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final outgoingFriendRequests =
            List<String>.from(userDoc.data()?['outgoingFriendRequests'] ?? []);
        return outgoingFriendRequests.contains(profileUid);
      }
    }
    return false;
  }

  Future<void> removeReceivedFriendRequest(String profileUid) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({
        'incomingFriendRequests': FieldValue.arrayRemove([profileUid])
      });
    }
    // update other persons outgoingFriendRequests
    final profileDocRef =
        FirebaseFirestore.instance.collection('users').doc(profileUid);
    await profileDocRef.update({
      'outgoingFriendRequests': FieldValue.arrayRemove([user!.uid])
    });
  }

  Future<bool> isFriendRequestReceived(String profileUid) async {
    // check if other user has sent a friend request
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final incomingFriendRequests =
            List<String>.from(userDoc.data()?['incomingFriendRequests'] ?? []);
        return incomingFriendRequests.contains(profileUid);
      }
    }
    return false;
  }

  Future<bool> areFriends(String profileUid) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final friends = List<String>.from(userDoc.data()?['friends'] ?? []);
        return friends.contains(profileUid);
      }
    }
    return false;
  }

  Future<void> removeFriend(String profileUid) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({
        'friends': FieldValue.arrayRemove([profileUid])
      });
    }
    // also remove the user from the other persons friends list
    final profileDocRef =
        FirebaseFirestore.instance.collection('users').doc(profileUid);
    await profileDocRef.update({
      'friends': FieldValue.arrayRemove([user!.uid])
    });
  }

  Future<void> makeFriends(String profileUid) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({
        'friends': FieldValue.arrayUnion([profileUid])
      });
    }
    // also add the user to the other persons friends list
    final profileDocRef =
        FirebaseFirestore.instance.collection('users').doc(profileUid);
    await profileDocRef.update({
      'friends': FieldValue.arrayUnion([user!.uid])
    });
    removeReceivedFriendRequest(profileUid);
    cancelFriendRequest(profileUid);
  }

  Future<List<Map<String, dynamic>>> fetchAllFriends() async {
    final user = _auth.currentUser; // Get current user
    List<Map<String, dynamic>> friendProfiles = [];

    if (user != null) {
      try {
        // Get current user's document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Check if user document exists and contains friends
        if (userDoc.exists) {
          final friends = List<String>.from(userDoc.data()?['friends'] ?? []);

          // Fetch the profiles for each friend UID
          for (String friendUid in friends) {
            final friendProfile = await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUid)
                .get();

            // Ensure the profile exists and add it to the friendProfiles list
            if (friendProfile.exists) {
              friendProfiles.add({
                'uid': friendUid,
                'firestoreData': friendProfile.data(),
              });
            }
          }

          // Optionally log the names of all friends
          for (var profile in friendProfiles) {
            dev.log(
                'Friend profile name: ${profile['firestoreData']['userName']}');
          }
        }
      } catch (e) {
        dev.log('Error fetching friends: $e');
      }
    }

    return friendProfiles; // Return the list of friend profiles
  }

  Future<List<Map<String, dynamic>>> fetchAllFriendRequestReceived() async {
    final user = _auth.currentUser; // Get current user
    List<Map<String, dynamic>> receivedRequests = [];

    if (user != null) {
      try {
        // Get current user's document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Check if user document exists and contains incoming friend requests
        if (userDoc.exists) {
          final incomingRequests = List<String>.from(
              userDoc.data()?['incomingFriendRequests'] ?? []);

          // Fetch the profiles for each incoming request UID
          for (String requestUid in incomingRequests) {
            final userProfile = await FirebaseFirestore.instance
                .collection('users')
                .doc(requestUid)
                .get();

            // Ensure the profile exists and add it to the receivedRequests list
            if (userProfile.exists) {
              receivedRequests.add({
                'uid': requestUid,
                'firestoreData': userProfile.data(),
              });
            }
          }

          // Optionally log the names of all received requests
          for (var request in receivedRequests) {
            dev.log(
                'Received friend request from: ${request['firestoreData']['userName']}');
          }
        }
      } catch (e) {
        dev.log('Error fetching received friend requests: $e');
      }
    }

    return receivedRequests; // Return the list of received friend requests
  }

  Future<List<Map<String, dynamic>>> fetchAllFriendRequestSent() async {
    final user = _auth.currentUser; // Get current user
    List<Map<String, dynamic>> sentRequests = [];

    if (user != null) {
      try {
        // Get current user's document from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Check if user document exists and contains outgoing friend requests
        if (userDoc.exists) {
          final outgoingRequests = List<String>.from(
              userDoc.data()?['outgoingFriendRequests'] ?? []);

          // Fetch the profiles for each outgoing request UID
          for (String requestUid in outgoingRequests) {
            final userProfile = await FirebaseFirestore.instance
                .collection('users')
                .doc(requestUid)
                .get();

            // Ensure the profile exists and add it to the sentRequests list
            if (userProfile.exists) {
              sentRequests.add({
                'uid': requestUid,
                'firestoreData': userProfile.data(),
              });
            }
          }

          // Optionally log the names of all sent requests
          for (var request in sentRequests) {
            dev.log(
                'Sent friend request to: ${request['firestoreData']['userName']}');
          }
        }
      } catch (e) {
        dev.log('Error fetching sent friend requests: $e');
      }
    }

    return sentRequests; // Return the list of sent friend requests
  }
}
