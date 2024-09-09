import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createPost({
    required String postDescription,
    required List<File> images,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }

    final String uid = user.uid;
    final DateTime timestamp = DateTime.now();
    List<String> imageUrls = [];

    try {
      // Upload each image to Firebase Storage
      for (var image in images) {
        final ref = _storage
            .ref()
            .child('posts/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = await ref.putFile(image);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      final postData = {
        'postDescription': postDescription,
        'createdAt': timestamp.toIso8601String(),
        'images': imageUrls,
        'likes': [],
        'comments': [],
      };

      // Store post in Firestore
      final docRef = _firestore.collection('users').doc(uid);

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
