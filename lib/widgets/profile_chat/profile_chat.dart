import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class ProfileChat extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onHeaderTapped;

  const ProfileChat(
      {super.key, required this.profile, required this.onHeaderTapped});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileChatState createState() => _ProfileChatState();
}

class _ProfileChatState extends State<ProfileChat> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onHeaderTapped,
          child: _buildChatHeader(context),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.transparent,
              child: const ChatMessages(), // Use the ChatMessages widget here
            ),
          ),
        ),
        _buildMessageInput(context),
      ],
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    final firstImage =
        widget.profile.images.isNotEmpty ? widget.profile.images.first : '';

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.greyLightest,
        border: Border(
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
                      widget.profile.userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
                if (widget.profile.isDogOwner &&
                    widget.profile.dogName != null) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(Icons.pets_rounded,
                          color: AppColors.customBlack),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.profile.dogName!,
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
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.customBlack),
            onPressed: () {
              // Implement your functionality for the three dots here
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // 85% of device width
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(40.0),
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
                  border: InputBorder.none, // Remove the inner border
                ),
                style: const TextStyle(color: AppColors.customBlack),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: _hasText ? widget.profile.profileColor : AppColors.grey,
              ),
              onPressed: _hasText
                  ? () {
                      // Implement your send message functionality here
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatBubble(context, "Hello! How are you?", true),
          _buildChatBubble(context, "I'm good, thanks! How about you?", false),
          _buildChatBubble(
              context, "Doing great, just enjoying the day!", true),
          _buildChatBubble(context, "That's awesome! Any plans?", false),
          _buildChatBubble(
              context, "Not much, maybe a walk with the dog later.", true),
          _buildChatBubble(context, "Sounds fun! Enjoy!", false),
          _buildChatBubble(context, "Hello! How are you?", true),
          _buildChatBubble(context, "I'm good, thanks! How about you?", false),
          _buildChatBubble(
              context, "Doing great, just enjoying the day!", true),
          _buildChatBubble(context, "That's awesome! Any plans?", false),
          _buildChatBubble(
              context, "Not much, maybe a walk with the dog later.", true),
          _buildChatBubble(context, "Sounds fun! Enjoy!", false),
          // Add more dummy chat messages here if needed
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, String message, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSender ? AppColors.brownLight : AppColors.greyLightest,
          borderRadius: BorderRadius.circular(24.0),
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
    );
  }
}
