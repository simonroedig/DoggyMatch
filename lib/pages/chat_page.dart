// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/chat/chat_request_toggle.dart';
import 'package:doggymatch_flutter/widgets/profile_chat/chat_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/pages/notifiers/profile_close_notifier.dart';

class ChatPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;

  const ChatPage({super.key, required this.profileCloseNotifier});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final AuthService _authService = AuthService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isChatSelected = true;
  UserProfile? _selectedProfile;
  bool _isProfileOpen = false;
  double? _selectedDistance;

  StreamSubscription<QuerySnapshot>? _chatRoomsSubscription;
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.profileCloseNotifier.addListener(_onProfileClose);
    _listenToChatRooms();
  }

  @override
  void dispose() {
    widget.profileCloseNotifier.removeListener(_onProfileClose);
    _chatRoomsSubscription?.cancel();
    super.dispose();
  }

  void _onProfileClose() {
    if (widget.profileCloseNotifier.shouldCloseProfile) {
      _closeProfile();
      widget.profileCloseNotifier.reset();
      _listenToChatRooms(); // Re-fetch chat rooms after profile closes
    }
  }

  void handleToggle(bool isChat) {
    setState(() {
      isChatSelected = isChat;
    });
  }

  void _openProfile(UserProfile profile, String distance) {
    setState(() {
      _selectedProfile = profile;
      _isProfileOpen = true;
      _selectedDistance = double.parse(distance);
      Provider.of<UserProfileState>(context, listen: false).openProfile();
    });
  }

  void _closeProfile() {
    setState(() {
      _isProfileOpen = false;
      _selectedProfile = null;
    });
    Provider.of<UserProfileState>(context, listen: false).closeProfile();
  }

  void _listenToChatRooms() {
    _chatRoomsSubscription
        ?.cancel(); // Cancel any existing subscription before starting a new one

    _chatRoomsSubscription = FirebaseFirestore.instance
        .collection('chatrooms')
        .where('members', arrayContains: _currentUserId)
        .snapshots()
        .listen((snapshot) async {
      final List<Map<String, dynamic>> chatRooms = [];

      final UserProfile? currentUserProfile =
          await _authService.fetchUserProfile();

      for (var chatRoom in snapshot.docs) {
        final otherUserId = (chatRoom.data() as Map<String, dynamic>)['members']
            .where((id) => id != _currentUserId)
            .first;

        final UserProfile? otherUserProfile =
            await _authService.fetchOtherUserProfile(otherUserId);

        final messagesSnapshot = await chatRoom.reference
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

        if (otherUserProfile != null && messagesSnapshot.docs.isNotEmpty) {
          final lastMessage = messagesSnapshot.docs.first['message'];

          final double distance = _calculateDistance(
            currentUserProfile!.latitude,
            currentUserProfile.longitude,
            otherUserProfile.latitude,
            otherUserProfile.longitude,
          );

          bool userSentMessage = false;
          bool otherUserSentMessage = false;

          for (var messageDoc in messagesSnapshot.docs) {
            String senderId = messageDoc['senderId'];

            if (senderId == _currentUserId) {
              userSentMessage = true;
            } else if (senderId == otherUserId) {
              otherUserSentMessage = true;
            }

            if (userSentMessage && otherUserSentMessage) {
              break;
            }
          }

          String chatRoomState;
          if (userSentMessage && otherUserSentMessage) {
            chatRoomState = "COMMUNICATION";
          } else if (userSentMessage) {
            chatRoomState = "OUTGOING";
          } else if (otherUserSentMessage) {
            chatRoomState = "INCOMING";
          } else {
            chatRoomState = "NO MESSAGES";
          }

          chatRooms.add({
            'profile': otherUserProfile,
            'lastMessage': lastMessage,
            'distance': distance.toStringAsFixed(1),
            'chatRoomState': chatRoomState,
          });

          developer.log('ChatRoomState: $chatRoomState');
        }
      }

      setState(() {
        _chatRooms = chatRooms;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> incomingRequests = _chatRooms
        .where((chatRoom) => chatRoom['chatRoomState'] == "INCOMING")
        .toList();

    final List<Map<String, dynamic>> outgoingRequests = _chatRooms
        .where((chatRoom) => chatRoom['chatRoomState'] == "OUTGOING")
        .toList();

    final List<Map<String, dynamic>> communicationChats = _chatRooms
        .where((chatRoom) => chatRoom['chatRoomState'] == "COMMUNICATION")
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const CustomAppBar(
        showSearchIcon: true,
        showFilterIcon: false,
        onSettingsPressed: null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 5),
              ChatRequestToggle(onToggle: handleToggle),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isChatSelected
                        ? communicationChats.isEmpty
                            ? const Center(child: Text('No chats available'))
                            : ListView.builder(
                                itemCount: communicationChats.length,
                                itemBuilder: (context, index) {
                                  final chatRoom = communicationChats[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: ChatCard(
                                      otherUserProfile:
                                          chatRoom['profile'] as UserProfile,
                                      lastMessage:
                                          chatRoom['lastMessage'] as String,
                                      onTap: () {
                                        _openProfile(
                                            chatRoom['profile'] as UserProfile,
                                            chatRoom['distance'] as String);
                                      },
                                    ),
                                  );
                                },
                              )
                        : ListView(
                            children: [
                              const Center(
                                child: Text(
                                  "< Incoming Requests",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.customBlack,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (incomingRequests.isEmpty)
                                const Center(
                                  child: Text(
                                    "(No incoming chat requests)",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.customBlack,
                                    ),
                                  ),
                                )
                              else
                                ...incomingRequests.map((chatRoom) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: ChatCard(
                                        otherUserProfile:
                                            chatRoom['profile'] as UserProfile,
                                        lastMessage:
                                            chatRoom['lastMessage'] as String,
                                        onTap: () {
                                          _openProfile(
                                              chatRoom['profile']
                                                  as UserProfile,
                                              chatRoom['distance'] as String);
                                        },
                                      ),
                                    )),
                              const SizedBox(height: 30),
                              const Center(
                                child: Text(
                                  "Outgoing Requests >",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.customBlack,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (outgoingRequests.isEmpty)
                                const Center(
                                  child: Text(
                                    "(No outgoing chat requests)",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.customBlack,
                                    ),
                                  ),
                                )
                              else
                                ...outgoingRequests.map((chatRoom) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: ChatCard(
                                        otherUserProfile:
                                            chatRoom['profile'] as UserProfile,
                                        lastMessage:
                                            chatRoom['lastMessage'] as String,
                                        onTap: () {
                                          _openProfile(
                                              chatRoom['profile']
                                                  as UserProfile,
                                              chatRoom['distance'] as String);
                                        },
                                      ),
                                    )),
                            ],
                          ),
              ),
            ],
          ),
          if (_isProfileOpen && _selectedProfile != null)
            Positioned.fill(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _closeProfile,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Colors.transparent,
                        child: ProfileWidget(
                          profile: _selectedProfile!,
                          clickedOnOtherUser: true,
                          distance: _selectedDistance ?? 0.0,
                          startInChat: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
