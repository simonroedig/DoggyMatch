// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:developer' as developer;
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_widget.dart';
import 'package:doggymatch_flutter/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/toggles/chat_request_toggle.dart';
import 'package:doggymatch_flutter/root_pages/chat_page_widgets/chat_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/notifiers/profile_close_notifier.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/classes/last_message.dart';

class ChatPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;

  const ChatPage({super.key, required this.profileCloseNotifier});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  final _authProfile = ProfileService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isChatSelected = true;
  bool _startInChat = true;
  UserProfile? _selectedProfile;
  bool _isProfileOpen = false;
  double? _selectedDistance;
  String? _lastOnline;
  bool? _isSaved;
  bool _hasOpenedProfileFromUserId = false;

  StreamSubscription<QuerySnapshot>? _chatRoomsSubscription;
  List<Map<String, dynamic>> _chatRooms = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // Tell Flutter to keep this widget alive

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasOpenedProfileFromUserId) {
      final userProfileState =
          Provider.of<UserProfileState>(context, listen: false);
      final userId = userProfileState.userIdToOpen;
      if (userId != null) {
        developer.log('Opening profile from user id: $userId');
        _openProfileById(userId);
        _hasOpenedProfileFromUserId = true;
        userProfileState.resetUserIdToOpen();
      }
    }
  }

  void _openProfileById(String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final profileData =
            await ProfileService().fetchOtherUserProfile(userId);
        if (profileData != null && mounted) {
          final userProfile = profileData;
          final userProfileState =
              Provider.of<UserProfileState>(context, listen: false);
          final distance = calculateDistance(
            userProfileState.userProfile.latitude,
            userProfileState.userProfile.longitude,
            userProfile.latitude,
            userProfile.longitude,
          ).toStringAsFixed(1);
          final lastOnline = calculateLastOnlineLong(userProfile.lastOnline);
          final isSaved = await ProfileService().isProfileSaved(userId);

          // Open profile automatically
          _openProfile(userProfile, distance, lastOnline, isSaved,
              startInChat: false);
        }
      } catch (e) {
        if (mounted) {
          developer.log('Error loading profile: $e');
        }
      }
    });
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

  void _openProfile(
      UserProfile profile, String distance, String lastOnline, bool isSaved,
      {bool startInChat = true}) {
    setState(() {
      _selectedProfile = profile;
      _isProfileOpen = true;
      _selectedDistance = double.parse(distance);
      _lastOnline = lastOnline;
      _isSaved = isSaved;
      _startInChat = startInChat;
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
          await _authProfile.fetchUserProfile();

      for (var chatRoom in snapshot.docs) {
        final otherUserId = (chatRoom.data())['members']
            .where((id) => id != _currentUserId)
            .first;

        // if the other user is blocked, skip this chat room
        final reportService = ReportService();
        if (await reportService.isBlocked(otherUserId)) {
          continue;
        }

        final UserProfile? otherUserProfile =
            await _authProfile.fetchOtherUserProfile(otherUserId);

        final messagesSnapshot = await chatRoom.reference
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

        if (otherUserProfile != null && messagesSnapshot.docs.isNotEmpty) {
          // Create a ValueNotifier<LastMessage>
          final ValueNotifier<LastMessage> lastMessageNotifier =
              ValueNotifier<LastMessage>(
            LastMessage(
              text: messagesSnapshot.docs.first['message'],
              senderId: messagesSnapshot.docs.first['senderId'],
            ),
          );

          // Listen to updates on the messages collection for real-time updates
          chatRoom.reference
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .snapshots()
              .listen((messageSnapshot) {
            if (messageSnapshot.docs.isNotEmpty) {
              lastMessageNotifier.value = LastMessage(
                text: messageSnapshot.docs.first['message'],
                senderId: messageSnapshot.docs.first['senderId'],
              );
            }
          });

          final double distance = calculateDistance(
            currentUserProfile!.latitude,
            currentUserProfile.longitude,
            otherUserProfile.latitude,
            otherUserProfile.longitude,
          );

          final String lastOnline =
              calculateLastOnlineLong(otherUserProfile.lastOnline);

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

          final bool isSaved = await _authProfile.isProfileSaved(otherUserId);

          chatRooms.add({
            'profile': otherUserProfile,
            'lastMessageNotifier': lastMessageNotifier,
            'distance': distance.toStringAsFixed(1),
            'lastOnline': lastOnline,
            'chatRoomState': chatRoomState,
            'isSaved': isSaved,
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
    super.build(
        context); // Important: call super.build when using AutomaticKeepAliveClientMixin
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
      appBar: CustomAppBar(
        showSearchIcon: true,
        showFilterIcon: false,
        onSettingsPressed: null,
        isProfileOpen: Provider.of<UserProfileState>(context).isProfileOpen,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 5),
              ChatRequestToggle(onToggle: handleToggle),
              const SizedBox(height: 15),
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
                                        vertical: 5.0),
                                    child: ChatCard(
                                      otherUserProfile:
                                          chatRoom['profile'] as UserProfile,
                                      lastMessageNotifier:
                                          chatRoom['lastMessageNotifier']
                                              as ValueNotifier<LastMessage>,
                                      onTap: () {
                                        _openProfile(
                                            chatRoom['profile'] as UserProfile,
                                            chatRoom['distance'] as String,
                                            chatRoom['lastOnline'] as String,
                                            chatRoom['isSaved'] as bool? ??
                                                false);
                                      },
                                    ),
                                  );
                                },
                              )
                        : ListView(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.message_rounded,
                                      color: AppColors.customBlack),
                                  const SizedBox(width: 4),
                                  Transform.translate(
                                    offset: const Offset(-6, -3),
                                    child: const Icon(
                                        Icons.call_received_rounded,
                                        size: 16,
                                        color: AppColors.customBlack),
                                  ),
                                  const SizedBox(width: 0),
                                  const Text(
                                    "Incoming Requests",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.customBlack,
                                    ),
                                  ),
                                ],
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
                                        lastMessageNotifier:
                                            chatRoom['lastMessageNotifier']
                                                as ValueNotifier<LastMessage>,
                                        onTap: () {
                                          _openProfile(
                                              chatRoom['profile']
                                                  as UserProfile,
                                              chatRoom['distance'] as String,
                                              chatRoom['lastOnline'] as String,
                                              chatRoom['isSaved'] as bool? ??
                                                  false);
                                        },
                                      ),
                                    )),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Outgoing Requests",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.customBlack,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.message_rounded,
                                      color: AppColors.customBlack),
                                  const SizedBox(width: 4),
                                  Transform.translate(
                                    offset: const Offset(-6, -3),
                                    child: const Icon(Icons.call_made_rounded,
                                        size: 16, color: AppColors.customBlack),
                                  ),
                                ],
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
                                        lastMessageNotifier:
                                            chatRoom['lastMessageNotifier']
                                                as ValueNotifier<LastMessage>,
                                        onTap: () {
                                          _openProfile(
                                              chatRoom['profile']
                                                  as UserProfile,
                                              chatRoom['distance'] as String,
                                              chatRoom['lastOnline'] as String,
                                              chatRoom['isSaved'] as bool? ??
                                                  false);
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
                        borderRadius:
                            BorderRadius.circular(UIConstants.outerRadius),
                        color: Colors.transparent,
                        child: ProfileWidget(
                          profile: _selectedProfile!,
                          clickedOnOtherUser: true,
                          distance: _selectedDistance ?? 0.0,
                          lastOnline: _lastOnline ?? '',
                          isProfileSaved: _isSaved ?? false,
                          startInChat: _startInChat,
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
}
