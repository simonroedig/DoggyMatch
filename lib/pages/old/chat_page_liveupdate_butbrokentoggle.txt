// ignore_for_file: library_private_types_in_public_api

import 'dart:math';
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

  @override
  void initState() {
    super.initState();
    widget.profileCloseNotifier.addListener(_onProfileClose);
  }

  @override
  void dispose() {
    widget.profileCloseNotifier.removeListener(_onProfileClose);
    super.dispose();
  }

  void _onProfileClose() {
    if (widget.profileCloseNotifier.shouldCloseProfile) {
      _closeProfile();
      widget.profileCloseNotifier.reset();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _authService.fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Failed to load profile'));
        }

        final currentUserProfile = snapshot.data;

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: const CustomAppBar(
            showSearchIcon: true,
            showFilterIcon: false,
            onSettingsPressed: null,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('members', arrayContains: _currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No chats available'));
              }

              final List<Map<String, dynamic>> chatRooms = [];

              for (var chatRoom in snapshot.data!.docs) {
                final otherUserId =
                    (chatRoom.data() as Map<String, dynamic>)['members']
                        .where((id) => id != _currentUserId)
                        .first;

                final messagesSnapshot = chatRoom.reference
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots();

                final otherUserProfileFuture =
                    _authService.fetchOtherUserProfile(otherUserId);

                chatRooms.add({
                  'messagesSnapshot': messagesSnapshot,
                  'otherUserProfileFuture': otherUserProfileFuture,
                });
              }

              return Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      ChatRequestToggle(onToggle: handleToggle),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: chatRooms.length,
                          itemBuilder: (context, index) {
                            final chatRoom = chatRooms[index];

                            return StreamBuilder<QuerySnapshot>(
                              stream: chatRoom['messagesSnapshot'],
                              builder: (context, messageSnapshot) {
                                if (messageSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!messageSnapshot.hasData ||
                                    messageSnapshot.data!.docs.isEmpty) {
                                  return Container();
                                }

                                final lastMessage =
                                    messageSnapshot.data!.docs.first['message'];

                                return FutureBuilder<UserProfile?>(
                                  future: chatRoom['otherUserProfileFuture'],
                                  builder: (context, userProfileSnapshot) {
                                    if (!userProfileSnapshot.hasData) {
                                      return Container();
                                    }

                                    final otherUserProfile =
                                        userProfileSnapshot.data!;
                                    final distance = _calculateDistance(
                                      currentUserProfile!.latitude,
                                      currentUserProfile.longitude,
                                      otherUserProfile.latitude,
                                      otherUserProfile.longitude,
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: ChatCard(
                                        otherUserProfile: otherUserProfile,
                                        lastMessage: lastMessage,
                                        onTap: () {
                                          _openProfile(otherUserProfile,
                                              distance.toStringAsFixed(1));
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
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
              );
            },
          ),
        );
      },
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
