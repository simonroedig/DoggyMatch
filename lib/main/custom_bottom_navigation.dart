import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabTapped;
  final bool showCloseButton;
  final VoidCallback? onCloseButtonTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.activeIndex,
    required this.onTabTapped,
    this.showCloseButton = false,
    this.onCloseButtonTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: BottomAppBar(
        color: AppColors.bg,
        shape: const CircularNotchedRectangle(),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            decoration: BoxDecoration(
              color: AppColors.brownLightest,
              borderRadius: BorderRadius.circular(80.0),
              border: Border.all(
                color: Colors.black,
                width: 3.0,
              ),
            ),
            child:
                showCloseButton ? _buildCloseButton() : _buildNavigationIcons(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _buildIcon(0, Icons.search_rounded)), // Search Icon

        _buildChatIconWithNotification(), // Chat Icon with notification
        Expanded(
            child: _buildIcon(3, Icons.people_alt_rounded)), // Community Icon
        Expanded(child: _buildIcon(2, Icons.person_rounded)), // Profile Icon
      ],
    );
  }

  Widget _buildIcon(int index, IconData icon) {
    bool isActive = activeIndex == index;
    Color highlightColor = _getHighlightColor(index);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30.0,
            color: isActive ? highlightColor : AppColors.customBlack,
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Container(
                width: 30.0,
                height: 3.0,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        log("Close button tapped in nav bar");
        if (onCloseButtonTapped != null) {
          onCloseButtonTapped!();
        }
      },
      child: Center(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
          child: Container(
            width: double.infinity,
            height: 60.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.customBlack,
              size: 35.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatIconWithNotification() {
    return Expanded(
      child: StreamBuilder<bool>(
        stream: _hasUnseenMessagesStream(),
        builder: (context, snapshot) {
          bool hasUnseenMessages = snapshot.data ?? false;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onTabTapped(1), // Index 1 for the chat page
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.message_rounded,
                      size: 30.0,
                      color: activeIndex == 1
                          ? _getHighlightColor(1)
                          : AppColors.customBlack,
                    ),
                    if (activeIndex == 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Container(
                          width: 30.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            color: _getHighlightColor(1),
                            shape: BoxShape.rectangle,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(40.0)),
                          ),
                        ),
                      ),
                  ],
                ),
                if (hasUnseenMessages)
                  Positioned(
                    top: 0,
                    right: 24,
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                        color: AppColors.customGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.customBlack,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Stream<bool> _hasUnseenMessagesStream() {
    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('chatrooms')
        .where('members', arrayContains: currentUserID)
        .snapshots()
        .map((snapshot) {
      for (var doc in snapshot.docs) {
        String seenStatusField = '${currentUserID}_hasSeenAllAndLastMessage';
        if (!(doc.data()['chatSeenBy'][seenStatusField] ?? true)) {
          return true;
        }
      }
      return false;
    });
  }

  Color _getHighlightColor(int index) {
    return AppColors.customBlack;
  }
}
