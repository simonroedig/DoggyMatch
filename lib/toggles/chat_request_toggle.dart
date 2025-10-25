// File: chat_request_toggle.dart

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class ChatRequestToggle extends StatefulWidget {
  final Function(bool) onToggle; // Callback for when the toggle is changed
  final bool currentSelected; // Current state passed from parent

  const ChatRequestToggle(
      {super.key, required this.onToggle, this.currentSelected = true});

  @override
  // ignore: library_private_types_in_public_api
  _ChatRequestToggleState createState() => _ChatRequestToggleState();
}

class _ChatRequestToggleState extends State<ChatRequestToggle> {
  late bool isChatSelected;

  @override
  void initState() {
    super.initState();
    isChatSelected = widget.currentSelected;
  }

  @override
  void didUpdateWidget(covariant ChatRequestToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSelected != oldWidget.currentSelected) {
      if (mounted) {
        setState(() {
          isChatSelected = widget.currentSelected;
        });
      }
    }
  }

  void toggleSwitch() {
    if (mounted) {
      setState(() {
        isChatSelected = !isChatSelected;
      });
    }

    widget.onToggle(isChatSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        margin: const EdgeInsets.only(
            top: 0.0, left: 16.0, right: 16.0, bottom: 0.0),
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
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
                    topLeft: Radius.circular(UIConstants.outerRadius),
                    bottomLeft: Radius.circular(UIConstants.outerRadius),
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
                    topRight: Radius.circular(UIConstants.outerRadius),
                    bottomRight: Radius.circular(UIConstants.outerRadius),
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
