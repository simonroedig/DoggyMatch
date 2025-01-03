import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
  }) async {
    final String reporterId = _auth.currentUser!.uid;

    try {
      // 1. Create a new report document
      final DocumentReference reportDocRef =
          await _firestore.collection('reports').add({
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. (Optional) Block the reported user for the reporter
      await _firestore
          .collection('users')
          .doc(reporterId)
          .collection('blockedUsers')
          .doc(reportedUserId)
          .set({
        'blockedAt': FieldValue.serverTimestamp(),
        'reason': reason,
      });

      // 3. Fetch the chat messages between the reporter and the reported user
      List<String> userIds = [reporterId, reportedUserId];
      userIds.sort();
      String chatRoomId = userIds.join('_');

      // In this example, we only fetch the *most recent 20 messages*
      final QuerySnapshot chatSnapshot = await _firestore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      // 4. Store a snapshot of these messages inside a subcollection of the report
      for (var messageDoc in chatSnapshot.docs) {
        // Copy the message data into the 'chatMessages' subcollection
        await reportDocRef.collection('chatMessages').add({
          ...messageDoc.data() as Map<String, dynamic>,
        });
      }

      // Additional logic if needed:
      // - Possibly send a notification to admins or log an event, etc.
    } catch (e) {
      // Handle or rethrow as needed
      rethrow;
    }
  }
}
