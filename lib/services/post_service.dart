import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // add images to here
  // they must be upload to firestore storage somehow, maybe like this
  /*
  final ref = _storage.ref().child(
          'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await ref.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
  */
  // and they must then be added to the post data

  Future<void> createPost({
    required String postDescription,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }

    final String uid = user.uid;
    final DateTime timestamp = DateTime.now();
    // add also fields for like (liked by uid), and comments (by uid, and content)
    // (should empty at creation)

    try {
      final docRef = _firestore.collection('users').doc(uid);

      final postData = {
        'postDescription': postDescription,
        'createdAt': timestamp.toIso8601String(),
        // add images reference/data too
      };

      // Add announcement as a sub-collection entry within the user's document
      await docRef
          .collection('user_posts')
          .doc(timestamp.toIso8601String())
          .set(postData);

      log('Post created successfully');
    } catch (e) {
      log('Error creating Post: $e');
    }
  }
}
