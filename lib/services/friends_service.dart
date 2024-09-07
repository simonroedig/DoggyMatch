import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a user's profile UID to the current user's saved profiles
  Future<void> sendFriendRequest(String profileUid) async {
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

  // Cancel a friend request
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

  // check if a friend request has been sent
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

  // remove received friend request
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

  // check if other user has sent a friend request
  Future<bool> isFriendRequestReceived(String profileUid) async {
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

  // check if users are friends
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

  // remove friend
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

  // make users friends
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
}
