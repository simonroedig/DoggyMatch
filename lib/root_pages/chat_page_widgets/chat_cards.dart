// File: lib/widgets/profile_chat/chat_cards.dart

// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
// Import necessary services and helpers
import 'package:doggymatch_flutter/shared_helper/icon_helpers.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/shared_helper/autoscrolling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doggymatch_flutter/classes/last_message.dart';

class ChatCard extends StatefulWidget {
  final UserProfile otherUserProfile;
  final ValueNotifier<LastMessage> lastMessageNotifier;
  final VoidCallback onTap;

  const ChatCard({
    Key? key,
    required this.otherUserProfile,
    required this.lastMessageNotifier,
    required this.onTap,
  }) : super(key: key);

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> with TickerProviderStateMixin {
  // Instantiate services and helpers
  final iconHelpers = IconHelpers();
  final _authProfile = ProfileService();
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_animationController)
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
              _animation.value * _scrollController.position.maxScrollExtent);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
              _animationController.forward(from: 0.0);
            }
          });
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getUserStatus(String userId) async {
    bool isSaved = await _isProfileSaved(userId);
    String friendStatus = await iconHelpers.determineFriendStatus(userId);
    return {
      'isSaved': isSaved,
      'friendStatus': friendStatus,
    };
  }

  Future<bool> _isProfileSaved(String userId) async {
    return await _authProfile.isProfileSaved(userId);
  }

  // Reintroduce the _chatSeenStatusStream method
  Stream<bool> _chatSeenStatusStream() {
    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    List<String> ids = [currentUserID, widget.otherUserProfile.uid];
    ids.sort();
    String chatRoomID = ids.join('_');

    String seenStatusField = '${currentUserID}_hasSeenAllAndLastMessage';

    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomID)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data['chatSeenBy'] != null) {
          return data['chatSeenBy'][seenStatusField] ?? true;
        }
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserStatus(widget.otherUserProfile.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // or a loading placeholder
        }

        bool isSaved = snapshot.data!['isSaved'];
        String friendStatus = snapshot.data!['friendStatus'];
        final profileColor = widget.otherUserProfile.profileColor;
        final profileImage = widget.otherUserProfile.images.isNotEmpty
            ? widget.otherUserProfile.images[0]
            : '';
        final isDogOwner = widget.otherUserProfile.isDogOwner;
        final dogName = widget.otherUserProfile.dogName ?? '';
        final userName = widget.otherUserProfile.userName;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
              color: profileColor,
              borderRadius: BorderRadius.circular(UIConstants.outerRadius),
              border: Border.all(color: AppColors.customBlack, width: 3),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image with Icons
                    Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(UIConstants.innerRadius),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.customBlack, width: 3),
                              borderRadius: BorderRadius.circular(
                                  UIConstants.innerRadius),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  UIConstants.innerRadiusClipped),
                              child: Image.network(
                                profileImage,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Friend Icon
                        if (friendStatus != 'none')
                          Positioned(
                            bottom: -4,
                            left: -4,
                            child: iconHelpers.buildFriendStatusIcon(
                                friendStatus, profileColor, 3),
                          ),
                        // Save Icon
                        if (isSaved)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: iconHelpers.buildSaveIcon(
                                true, profileColor, 3, 20),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10.0),
                    // User Info and Last Message
                    Expanded(
                      child: Container(
                        height: 74,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0.0),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius:
                              BorderRadius.circular(UIConstants.innerRadius),
                          border: Border.all(
                              color: AppColors.customBlack, width: 3),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoScrollingRow(
                              userName: userName,
                              isDogOwner: isDogOwner,
                              dogName: dogName,
                            ),
                            const SizedBox(height: 4),
                            StreamBuilder<bool>(
                              stream: _chatSeenStatusStream(),
                              builder: (context, seenSnapshot) {
                                bool isUnseen = false;
                                if (seenSnapshot.hasData) {
                                  isUnseen = !seenSnapshot.data!;
                                }

                                return ValueListenableBuilder<LastMessage>(
                                  valueListenable: widget.lastMessageNotifier,
                                  builder: (context, lastMessage, child) {
                                    // Determine if the last message was sent by the current user or the other user
                                    final bool isIncoming = lastMessage
                                            .senderId !=
                                        FirebaseAuth.instance.currentUser!.uid;

                                    // Choose the appropriate arrow icon
                                    IconData arrowIcon = isIncoming
                                        ? Icons.call_received_rounded
                                        : Icons.call_made_rounded;

                                    return Row(
                                      children: [
                                        // Message Icon
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.message_rounded,
                                          size: 14,
                                          color: isUnseen
                                              ? AppColors.customBlack
                                              : AppColors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        // Arrow Icon (incoming or outgoing)
                                        Transform.translate(
                                          offset: const Offset(-5, -3),
                                          child: Icon(
                                            arrowIcon,
                                            size: 12,
                                            color: isUnseen
                                                ? AppColors.customBlack
                                                : AppColors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 0),
                                        // Last Message Text
                                        Transform.translate(
                                          offset: const Offset(-4.0,
                                              0.0), // Adjust the value as needed
                                          child: Expanded(
                                            child: Text(
                                              lastMessage.text,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                fontWeight: isUnseen
                                                    ? FontWeight.bold
                                                    : FontWeight.w300,
                                                color: isUnseen
                                                    ? AppColors.customBlack
                                                    : AppColors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 0.0),
                    // Kebab Menu Icon
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: AppColors.customBlack, size: 24),
                      onPressed: () {
                        // Handle kebab menu actions here
                      },
                    ),
                  ],
                ),
                // Reintroduce the green circle indicator
                StreamBuilder<bool>(
                  stream: _chatSeenStatusStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.data!) {
                      return Positioned(
                        top: 0,
                        right: 10,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.customGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.customBlack,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
