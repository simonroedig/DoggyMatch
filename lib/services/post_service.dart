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
        'postOwner': uid,
        'postId': '$uid|${timestamp.toIso8601String()}',
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
          .doc('$uid|${timestamp.toIso8601String()}')
          .set(postData);

      log('Post created successfully');
    } catch (e) {
      log('Error creating Post: $e');
    }
  }

  // New method to like a post
  Future<void> likePost(String postOwnerId, String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }
    final String uid = user.uid;

    // log the two parameters of this function
    log('postOwnerId: $postOwnerId');
    log('postId: $postId');

    try {
      final postRef = _firestore
          .collection('users')
          .doc(postOwnerId)
          .collection('user_posts')
          .doc(postId);

      await postRef.update({
        'likes': FieldValue.arrayUnion([uid]),
      });

      log('Post liked successfully');
    } catch (e) {
      log('Error liking Post: $e');
    }
  }

  // New method to unlike a post
  Future<void> unlikePost(String postOwnerId, String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }
    final String uid = user.uid;

    try {
      final postRef = _firestore
          .collection('users')
          .doc(postOwnerId)
          .collection('user_posts')
          .doc(postId);

      await postRef.update({
        'likes': FieldValue.arrayRemove([uid]),
      });

      log('Post unliked successfully');
    } catch (e) {
      log('Error unliking Post: $e');
    }
  }

  // get all posts likes uid's
  Future<List<String>?> getPostLikes(String postOwnerId, String postId) async {
    try {
      final postRef = _firestore
          .collection('users')
          .doc(postOwnerId)
          .collection('user_posts')
          .doc(postId);

      final doc = await postRef.get();
      final data = doc.data() as Map<String, dynamic>;

      return List<String>.from(data['likes']);
    } catch (e) {
      log('Error getting Post likes: $e');
      return null;
    }
  }

  // Method to save a post using subcollection
// Method to save a post
  Future<void> savePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }
    final String uid = user.uid;

    try {
      final userRef = _firestore.collection('users').doc(uid);

      // Add the postId to the user's 'savedPosts' array
      await userRef.update({
        'savedPosts': FieldValue.arrayUnion([postId]),
      });

      log('Post saved successfully');
    } catch (e) {
      log('Error saving Post: $e');
    }
  }

  // Method to unsave a post
  Future<void> unsavePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }
    final String uid = user.uid;

    try {
      final userRef = _firestore.collection('users').doc(uid);

      // Remove the postId from the user's 'savedPosts' array
      await userRef.update({
        'savedPosts': FieldValue.arrayRemove([postId]),
      });

      log('Post unsaved successfully');
    } catch (e) {
      log('Error unsaving Post: $e');
    }
  }
}
