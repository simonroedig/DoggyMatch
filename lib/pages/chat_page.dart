// File: chat_page.dart

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/chat/chat_request_toggle.dart'; // Import the toggle widget

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isChatSelected = true; // Default to Chat being selected

  void handleToggle(bool isChat) {
    setState(() {
      isChatSelected = isChat;
    });
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
          Expanded(
            child: Center(
              child: Text(
                isChatSelected
                    ? "Chat Page Content goes here"
                    : "Request Page Content goes here",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: AppColors.customBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
