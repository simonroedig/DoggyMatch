import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createAnnouncement({
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
      final docRef = _firestore.collection('announcements').doc(uid);

      final announcementData = {
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
}
