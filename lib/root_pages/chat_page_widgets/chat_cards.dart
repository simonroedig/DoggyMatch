// File: lib/widgets/profile_chat/chat_cards.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatCard extends StatefulWidget {
  final UserProfile otherUserProfile;
  final ValueNotifier<String> lastMessageNotifier;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.otherUserProfile,
    required this.lastMessageNotifier,
    required this.onTap,
  });

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> with TickerProviderStateMixin {
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
        return snapshot['chatSeenBy'][seenStatusField] ?? true;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String firstImage = widget.otherUserProfile.images.isNotEmpty
        ? widget.otherUserProfile.images.first
        : '';

    return GestureDetector(
      onTap: widget.onTap,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: widget.otherUserProfile.profileColor,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: AppColors.customBlack, width: 3),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(21.0),
                        bottomLeft: Radius.circular(21.0),
                      ),
                      border: Border(
                        right:
                            BorderSide(color: AppColors.customBlack, width: 3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(21.0),
                        bottomLeft: Radius.circular(21.0),
                      ),
                      child: firstImage.startsWith('http')
                          ? Image.network(firstImage, fit: BoxFit.cover)
                          : Image.asset(firstImage, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Icon(Icons.person_rounded,
                                  color: AppColors.customBlack, size: 20),
                              const SizedBox(width: 4.0),
                              Text(
                                widget.otherUserProfile.userName,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.customBlack,
                                ),
                              ),
                              if (widget.otherUserProfile.isDogOwner &&
                                  widget.otherUserProfile.dogName != null) ...[
                                const Text(
                                  '  •  ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.customBlack,
                                    fontSize: 18.0,
                                  ),
                                ),
                                const Icon(Icons.pets_rounded,
                                    color: AppColors.customBlack, size: 18),
                                const SizedBox(width: 4.0),
                                Text(
                                  widget.otherUserProfile.dogName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.customBlack,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        ValueListenableBuilder<String>(
                          valueListenable: widget.lastMessageNotifier,
                          builder: (context, lastMessage, child) {
                            return Text(
                              lastMessage,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: AppColors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Icon(Icons.more_vert_rounded,
                      color: AppColors.customBlack, size: 28),
                  const SizedBox(width: 15.0),
                ],
              ),
              StreamBuilder<bool>(
                stream: _chatSeenStatusStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.data!) {
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.customGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.customBlack,
                            width: 2,
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
      ),
    );
  }
}
