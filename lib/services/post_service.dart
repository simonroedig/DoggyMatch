import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img; // Import the image package

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
        // Read the original image file as bytes
        final List<int> imageBytes = await image.readAsBytes();

        // Decode and resize/compress the image
        img.Image? decodedImage = img.decodeImage(imageBytes);
        if (decodedImage == null) continue;

        // Resize to a width of 800px while maintaining aspect ratio
        final img.Image resizedImage = img.copyResize(decodedImage, width: 800);

        // Compress the image to JPEG with quality 80
        final List<int> compressedImageBytes =
            img.encodeJpg(resizedImage, quality: 60);

        // Upload the compressed image to Firebase Storage
        final ref = _storage
            .ref()
            .child('posts/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask =
            await ref.putData(Uint8List.fromList(compressedImageBytes));
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
        'commentsCount': 0, // Initialize comments count
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

  Future<void> likePost(String postOwnerId, String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }
    final String uid = user.uid;

    log('postOwnerId: $postOwnerId');
    log('postId: $postId');

    try {
      final postRef = _firestore
          .collection('users')
          .doc(postOwnerId)
          .collection('user_posts')
          .doc(postId);

      final userRef = _firestore.collection('users').doc(uid);

      // Use a batch to perform atomic updates
      WriteBatch batch = _firestore.batch();

      // Update the post's likes array
      batch.update(postRef, {
        'likes': FieldValue.arrayUnion([uid]),
      });

      // Update the user's likedPosts array
      batch.update(userRef, {
        'likedPosts': FieldValue.arrayUnion([postId]),
      });

      // Commit the batch
      await batch.commit();

      log('Post liked and stored in user\'s likedPosts successfully');
    } catch (e) {
      log('Error liking Post: $e');
    }
  }

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

      final userRef = _firestore.collection('users').doc(uid);

      // Use a batch to perform atomic updates
      WriteBatch batch = _firestore.batch();

      // Update the post's likes array
      batch.update(postRef, {
        'likes': FieldValue.arrayRemove([uid]),
      });

      // Update the user's likedPosts array
      batch.update(userRef, {
        'likedPosts': FieldValue.arrayRemove([postId]),
      });

      // Commit the batch
      await batch.commit();

      log('Post unliked and removed from user\'s likedPosts successfully');
    } catch (e) {
      log('Error unliking Post: $e');
    }
  }

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

  Future<void> addComment(
      String postOwnerId, String postId, String commentText) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('No user is signed in');
      return;
    }
    final String uid = user.uid;

    // Fetch user's display name or username
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userName = userDoc.data()?['userName'] ?? 'Anonymous';

    final DateTime timestamp = DateTime.now();

    final commentData = {
      'commentId': '$uid|${timestamp.toIso8601String()}',
      'userId': uid,
      'userName': userName,
      'commentText': commentText,
      'createdAt': timestamp.toIso8601String(),
    };

    try {
      final postRef = _firestore
          .collection('users')
          .doc(postOwnerId)
          .collection('user_posts')
          .doc(postId);

      final commentRef =
          postRef.collection('comments').doc(commentData['commentId']);

      await commentRef.set(commentData);

      // Increment comments count
      await postRef.update({
        'commentsCount': FieldValue.increment(1),
      });

      log('Comment added successfully');
    } catch (e) {
      log('Error adding comment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(
      String postOwnerId, String postId) async {
    try {
      final commentsSnapshot = await _firestore
          .collection('users')
          .doc(postOwnerId)
          .collection('user_posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      return commentsSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting comments: $e');
      return [];
    }
  }
}
