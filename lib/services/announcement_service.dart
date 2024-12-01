import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createAnnouncement({
    required String announcementTitle,
    required String announcementText,
    required DateTime? showUntilDate,
    required bool showForever,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }

    final String uid = user.uid;
    final DateTime timestamp = DateTime.now();

    try {
      final docRef = _firestore.collection('users').doc(uid);

      // Delete existing announcements before creating a new one
      await deleteAnnouncement();

      final announcementData = {
        'announcementTitle': announcementTitle,
        'announcementText': announcementText,
        'createdAt': timestamp.toIso8601String(),
        'showUntil':
            showForever ? 'Show Forever' : showUntilDate?.toIso8601String(),
      };

      // Add announcement as a sub-collection entry within the user's document
      await docRef
          .collection('user_announcements')
          .doc(timestamp.toIso8601String())
          .set(announcementData);

      log('Announcement created successfully');
    } catch (e) {
      log('Error creating announcement: $e');
    }
  }

  Future<void> deleteAnnouncement() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }

    final String uid = user.uid;

    try {
      final docRef = _firestore.collection('users').doc(uid);

      // Get all documents in 'user_announcements' collection
      final announcementCollection = docRef.collection('user_announcements');
      final snapshot = await announcementCollection.get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      log('Announcement(s) deleted successfully');
    } catch (e) {
      log('Error deleting announcement: $e');
    }
  }

  Future<bool> hasAnnouncement() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return false;
    }

    final String uid = user.uid;

    try {
      final docRef = _firestore.collection('users').doc(uid);
      final announcementCollection = docRef.collection('user_announcements');

      // Check if there is at least one announcement
      final snapshot = await announcementCollection.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        log('User has existing announcement(s)');
        return true;
      } else {
        log('No existing announcements found');
        return false;
      }
    } catch (e) {
      log('Error checking for announcements: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAnnouncementForUser(String uid) async {
    if (uid.isEmpty) {
      log('Cannot fetch announcements: UID is null or empty.');
      return null;
    }
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final announcementCollection = docRef.collection('user_announcements');
      final snapshot = await announcementCollection.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        log('User has existing announcement(s)');
        return snapshot.docs.first.data();
      } else {
        log('No existing announcements found for user $uid');
        return null;
      }
    } catch (e) {
      log('Error fetching announcement for user $uid: $e');
      return null;
    }
  }
}
