// File: chat_request_toggle.dart

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class ChatRequestToggle extends StatefulWidget {
  final Function(bool) onToggle; // Callback for when the toggle is changed

  const ChatRequestToggle({super.key, required this.onToggle});

  @override
  // ignore: library_private_types_in_public_api
  _ChatRequestToggleState createState() => _ChatRequestToggleState();
}

class _ChatRequestToggleState extends State<ChatRequestToggle> {
  bool isChatSelected = true;

  void toggleSwitch() {
    setState(() {
      isChatSelected = !isChatSelected;
    });
    widget.onToggle(isChatSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chats toggle
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isChatSelected ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: !isChatSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    top: BorderSide(
                      color: !isChatSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide.none,
                    bottom: BorderSide(
                      color: !isChatSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.message_rounded,
                      color:
                          isChatSelected ? AppColors.bg : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Chats',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: isChatSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isChatSelected
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 2, // Divider between the toggles
              color: AppColors.customBlack,
            ),
            // Requests toggle with custom icon combination
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isChatSelected ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isChatSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: isChatSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    bottom: BorderSide(
                      color: isChatSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    left: BorderSide.none,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main message icon
                    Icon(
                      Icons.message_rounded,
                      size: 24,
                      color: !isChatSelected
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    // Smaller swap icon, offset for positioning
                    Transform.translate(
                      offset: const Offset(-6, -3),
                      child: Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: !isChatSelected
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Requests',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: !isChatSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: !isChatSelected
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
