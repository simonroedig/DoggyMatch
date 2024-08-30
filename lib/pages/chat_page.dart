// File: chat_page.dart

import 'package:doggymatch_flutter/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/chat/chat_request_toggle.dart';
import 'package:doggymatch_flutter/widgets/profile_chat/chat_cards.dart';
//import 'package:doggymatch_flutter/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isChatSelected = true; // Default to Chat being selected

  void handleToggle(bool isChat) {
    setState(() {
      isChatSelected = isChat;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchChatRooms() async {
    final List<Map<String, dynamic>> chatRooms = [];

    final QuerySnapshot chatRoomsSnapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('members', arrayContains: _currentUserId)
        .get();

    for (var chatRoom in chatRoomsSnapshot.docs) {
      final otherUserId = (chatRoom.data() as Map<String, dynamic>)['members']
          .where((id) => id != _currentUserId)
          .first;

      final UserProfile? otherUserProfile =
          await _authService.fetchOtherUserProfile(otherUserId);
      final lastMessageSnapshot = await chatRoom.reference
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (otherUserProfile != null && lastMessageSnapshot.docs.isNotEmpty) {
        final lastMessage = lastMessageSnapshot.docs.first['message'];
        chatRooms.add({
          'profile': otherUserProfile,
          'lastMessage': lastMessage,
        });
      }
    }
    return chatRooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const CustomAppBar(
        showSearchIcon: true, // Show search icon on chat page
        showFilterIcon: false, // Hide filter icon
        onSettingsPressed: null, // Add your settings logic here if needed
      ),
      body: Column(
        children: [
          const SizedBox(height: 5), // Add some spacing
          ChatRequestToggle(onToggle: handleToggle), // Add the toggle widget
          const SizedBox(height: 15), // Add some spacing
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchChatRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading chats'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No chats available'));
                }

                final chatRooms = snapshot.data!;

                return ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0), // Adjust the padding as needed
                      child: ChatCard(
                        otherUserProfile: chatRoom['profile'] as UserProfile,
                        lastMessage: chatRoom['lastMessage'] as String,
                        onTap: () {
                          // Handle chat card tap, e.g., navigate to chat details page
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
