// File: chat_request_toggle.dart

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';

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
                    right: BorderSide.none, // No border on the right side
                    bottom: BorderSide(
                      color: !isChatSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  isChatSelected ? '🐶 Chats' : 'Chats',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight:
                        isChatSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isChatSelected ? AppColors.bg : AppColors.customBlack,
                  ),
                ),
              ),
            ),
            Container(
              width: 2, // Adjusted the width to be consistent
              color: AppColors.customBlack,
            ),
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
                    left: BorderSide.none, // No border on the left side
                  ),
                ),
                child: Text(
                  !isChatSelected ? '🐶 Requests' : 'Requests',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight:
                        !isChatSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        !isChatSelected ? AppColors.bg : AppColors.customBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
