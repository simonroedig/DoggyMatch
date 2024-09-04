import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/widgets/profile_chat/chat_dialogs.dart';

class ProfileChat extends StatefulWidget {
  final UserProfile otherUserProfile;
  final VoidCallback onHeaderTapped;

  const ProfileChat({
    super.key,
    required this.otherUserProfile,
    required this.onHeaderTapped,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileChatState createState() => _ProfileChatState();
}

class _ProfileChatState extends State<ProfileChat> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
    WidgetsBinding.instance.addObserver(this);
    // Scroll to the bottom when the chat page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    _chatService.updateChatSeenStatus(widget.otherUserProfile.uid, true);
  }

  void _handleTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    await _chatService.sendMessage(
      widget.otherUserProfile.uid,
      widget.otherUserProfile.email,
      _controller.text,
    );

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.position.maxScrollExtent > 0) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Detect when the keyboard appears or disappears
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    if (bottomInset > 0.0) {
      // Keyboard is visible, scroll to bottom once
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          onTap: widget.onHeaderTapped,
          child: _buildChatHeader(context),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _chatService.getMessages(
                _currentUserId, widget.otherUserProfile.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs;

              // Auto-scroll when new messages are received or the chat is viewed for the first time
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final messageData = messages[index];
                  final isSender = messageData['senderId'] == _currentUserId;
                  final DateTime timestamp =
                      (messageData['timestamp'] as Timestamp).toDate();

                  bool shouldShowTimestamp = true;
                  if (index > 0) {
                    final previousMessageData = messages[index - 1];
                    final DateTime previousTimestamp =
                        (previousMessageData['timestamp'] as Timestamp)
                            .toDate();
                    shouldShowTimestamp =
                        !isSameMinute(timestamp, previousTimestamp);
                  }

                  return Column(
                    children: [
                      if (shouldShowTimestamp) _buildTimestamp(timestamp),
                      _buildChatBubble(
                          context, messageData['message'], isSender),
                    ],
                  );
                },
              );
            },
          ),
        ),
        _buildMessageInput(context),
      ],
    );
  }

  bool isSameMinute(DateTime timestamp1, DateTime timestamp2) {
    return timestamp1.year == timestamp2.year &&
        timestamp1.month == timestamp2.month &&
        timestamp1.day == timestamp2.day &&
        timestamp1.hour == timestamp2.hour &&
        timestamp1.minute == timestamp2.minute;
  }

  Widget _buildChatHeader(BuildContext context) {
    final firstImage = widget.otherUserProfile.images.isNotEmpty
        ? widget.otherUserProfile.images.first
        : '';

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: widget.otherUserProfile.profileColor,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.customBlack,
            width: 3.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppColors.customBlack,
                  width: 3.0,
                ),
              ),
            ),
            child: firstImage.startsWith('http')
                ? Image.network(firstImage, fit: BoxFit.cover)
                : Image.asset(firstImage, fit: BoxFit.cover),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        color: AppColors.customBlack),
                    const SizedBox(width: 8.0),
                    Text(
                      widget.otherUserProfile.userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
                if (widget.otherUserProfile.isDogOwner &&
                    widget.otherUserProfile.dogName != null) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(Icons.pets_rounded,
                          color: AppColors.customBlack),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.otherUserProfile.dogName!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.customBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.customBlack),
            onSelected: (String value) {
              switch (value) {
                case 'delete':
                  showDeleteConfirmationDialog(
                      context, widget.otherUserProfile.userName);
                  break;
                case 'hide':
                  showHideConfirmationDialog(
                      context, widget.otherUserProfile.userName);
                  break;
                case 'report':
                  showReportConfirmationDialog(
                      context, widget.otherUserProfile.userName);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'delete',
                child: Center(
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                    ),
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'hide',
                child: Center(
                  child: Text(
                    'Hide',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                    ),
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: Center(
                  child: Text(
                    'Report',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.customRed,
                    ),
                  ),
                ),
              ),
            ],
            offset: const Offset(
                -10, 40), // Adjust to position the menu beneath the icon
            color: AppColors.bg, // Custom background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Curved edges
              side: const BorderSide(
                color: AppColors.customBlack, // Border color
                width: 3.0, // Border width
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 14.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.84,
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: AppColors.customBlack,
              width: 3.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    hintText: 'Send a message..',
                    hintStyle: TextStyle(color: AppColors.grey),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppColors.customBlack),
                  minLines: 1, // Minimum number of lines for the text field
                  maxLines: 5, // Maximum number of lines for the text field
                  onTap: () {
                    // Scroll to the bottom after the keyboard is fully visible
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      //_scrollToBottom();
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: _hasText ? AppColors.customBlack : AppColors.grey,
                ),
                onPressed: _hasText ? _sendMessage : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, String message, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width *
              0.6, // Limit max width to 60% of screen width
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSender ? AppColors.brownLight : AppColors.greyLightest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24.0),
              topRight: const Radius.circular(24.0),
              bottomLeft: isSender
                  ? const Radius.circular(24.0)
                  : const Radius.circular(10.0),
              bottomRight: isSender
                  ? const Radius.circular(10.0)
                  : const Radius.circular(24.0),
            ),
            border: Border.all(
              color: AppColors.customBlack,
              width: 3.0,
            ),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.customBlack,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    final DateFormat dateFormat = DateFormat('EEE, d MMM • ');
    final DateFormat timeFormat = DateFormat('HH:mm');
    final String formattedDate = dateFormat.format(timestamp);
    final String formattedTime = timeFormat.format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$formattedDate ',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.customBlack,
                ),
              ),
              TextSpan(
                text: formattedTime,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
