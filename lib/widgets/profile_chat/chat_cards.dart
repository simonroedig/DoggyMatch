// File: lib/widgets/profile_chat/chat_cards.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class ChatCard extends StatefulWidget {
  final UserProfile otherUserProfile;
  final String lastMessage;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.otherUserProfile,
    required this.lastMessage,
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
      duration: const Duration(seconds: 5), // Adjust the duration as needed
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_animationController)
      ..addListener(() {
        if (_scrollController.hasClients) {
          // Check if the controller is attached to a scroll view
          _scrollController.jumpTo(
              _animation.value * _scrollController.position.maxScrollExtent);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Wait for 3 seconds before jumping back to the start
          Future.delayed(const Duration(seconds: 1), () {
            if (_scrollController.hasClients) {
              // Ensure the controller is still attached
              _scrollController.jumpTo(0);
              _animationController.forward(from: 0.0); // Restart the animation
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

  @override
  Widget build(BuildContext context) {
    final String firstImage = widget.otherUserProfile.images.isNotEmpty
        ? widget.otherUserProfile.images.first
        : '';

    return GestureDetector(
      onTap: widget.onTap,
      child: FractionallySizedBox(
        widthFactor: 0.9, // Adjust the width factor as needed
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: widget.otherUserProfile.profileColor,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: AppColors.customBlack, width: 3),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(21.0),
                    bottomLeft: Radius.circular(21.0),
                  ),
                  border: Border(
                    right: BorderSide(color: AppColors.customBlack, width: 3),
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
                              color: AppColors.customBlack,
                              size: 20), // Adjust the size as needed
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
                                color: AppColors.customBlack,
                                size: 18), // Adjust the size as needed
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
                    Text(
                      widget.lastMessage,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis, // Ellipsis added here
                      maxLines: 1, // Ensure it stays on one line
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
        ),
      ),
    );
  }
}
