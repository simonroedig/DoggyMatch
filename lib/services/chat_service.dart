import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:doggymatch_flutter/message/message.dart';

// https://www.youtube.com/watch?v=mBBycL0EtBQ
// watched until minute 32:00

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SEND MESSAGE
  Future<void> sendMessage(
      String receiverID, String receiverEmail, String message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final DateTime timestamp = DateTime.now();

    // create a new message
    Message newMessage = Message(
      senderId: currentUserID,
      senderEmail: currentUserEmail,
      receiverId: receiverID,
      receiverEmail: receiverEmail,
      message: message,
      timestamp: timestamp,
    );

    // construct chatroom id from sender and receiver id (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // add or update chatroom document with members array
    await _firestore.collection('chatrooms').doc(chatRoomID).set(
      {
        'members': ids,
        'chatSeenBy': {
          '${currentUserID}_hasSeenAllAndLastMessage': true,
          '${receiverID}_hasSeenAllAndLastMessage': false,
        },
      },
      SetOptions(
          merge:
              true), // SetOptions(merge: true) ensures you don't overwrite existing data.
    );

    // add message to firestore
    await _firestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // GET MESSAGE
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // GET CHATROOMS
  Future<List<Map<String, dynamic>>> getExistingChatroomforUser(
      String userID) async {
    List<Map<String, dynamic>> chatRooms = [];

    final QuerySnapshot chatRoomsSnapshot = await _firestore
        .collection('chatrooms')
        .where('members', arrayContains: userID)
        .get();
    log(chatRoomsSnapshot.docs.toString());

    for (var chatRoom in chatRoomsSnapshot.docs) {
      final otherUserID = (chatRoom.data() as Map<String, dynamic>)['members']
          .where((id) => id != userID)
          .first;

      final lastMessageSnapshot = await chatRoom.reference
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastMessageSnapshot.docs.isNotEmpty) {
        final lastMessage = lastMessageSnapshot.docs.first['message'];
        chatRooms.add({
          'otherUserID': otherUserID,
          'lastMessage': lastMessage,
        });
      }
    }

    return chatRooms;
  }

  // UPDATE chatSeenBy
  Future<void> updateChatSeenStatus(
      String receiverID, bool hasSeenAllAndLastMessage) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;

    // construct chatroom id from sender and receiver id (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // create a field name based on the current user id
    String seenStatusField = '${currentUserID}_hasSeenAllAndLastMessage';

    // reference to the chatroom document
    DocumentReference chatRoomDoc =
        _firestore.collection('chatrooms').doc(chatRoomID);

    // check if the chatroom document exists
    DocumentSnapshot chatRoomSnapshot = await chatRoomDoc.get();

    if (chatRoomSnapshot.exists) {
      // update the 'chatSeenBy' field in the chatroom document
      await chatRoomDoc.update({
        'chatSeenBy.$seenStatusField': hasSeenAllAndLastMessage,
      }).catchError((error) {
        log('Failed to update chatSeenBy field: $error');
      });
    } else {
      log('Chatroom does not exist, no update performed.');
    }
  }

  // GET chatSeenBy
  Future<bool> getChatSeenStatus(String receiverID) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;

    // construct chatroom id from sender and receiver id (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // create a field name based on the current user id
    String seenStatusField = '${currentUserID}_hasSeenAllAndLastMessage';

    // get the 'chatSeenBy' field in the chatroom document
    final DocumentSnapshot chatRoomSnapshot =
        await _firestore.collection('chatrooms').doc(chatRoomID).get();

    if (chatRoomSnapshot.exists) {
      return chatRoomSnapshot['chatSeenBy'][seenStatusField];
    } else {
      return true;
    }
  }
}
