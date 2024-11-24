// ignore_for_file: library_private_types_in_public_api

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class FriendsReceivedReqSentReqToggle extends StatefulWidget {
  final Function(int) onToggle; // Callback for when the toggle changes

  const FriendsReceivedReqSentReqToggle({super.key, required this.onToggle});

  @override
  _FriendsReceivedReqSentReqToggleState createState() =>
      _FriendsReceivedReqSentReqToggleState();
}

class _FriendsReceivedReqSentReqToggleState
    extends State<FriendsReceivedReqSentReqToggle> {
  int currentState = 0; // 0 = Friends, 1 = Received, 2 = Sent

  void toggleSwitch(int index) {
    setState(() {
      currentState = index;
    });
    widget.onToggle(currentState);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin:
          const EdgeInsets.only(top: 0.0, left: 16.0, right: 16.0, bottom: 0.0),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.outerRadius),
        border: Border.all(color: AppColors.customBlack, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Friends state
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      currentState == 0 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UIConstants.outerRadiusClipped),
                    bottomLeft: Radius.circular(UIConstants.outerRadiusClipped),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.people_alt_rounded,
                      size: 24,
                      color: currentState == 0
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Transform.translate(
                      offset: const Offset(-6, -3),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: currentState == 0
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 2,
            color: AppColors.customBlack,
          ),
          // Received state
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(1),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      currentState == 1 ? AppColors.customBlack : AppColors.bg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.people_alt_rounded,
                      size: 24,
                      color: currentState == 1
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Transform.translate(
                      offset: const Offset(-6, -3),
                      child: Icon(
                        Icons.call_received_rounded,
                        size: 16,
                        color: currentState == 1
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 2,
            color: AppColors.customBlack,
          ),
          // Sent state
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(2),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      currentState == 2 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(UIConstants.outerRadiusClipped),
                    bottomRight:
                        Radius.circular(UIConstants.outerRadiusClipped),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.people_alt_rounded,
                      size: 24,
                      color: currentState == 2
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Transform.translate(
                      offset: const Offset(-6, -3),
                      child: Icon(
                        Icons.call_made_rounded,
                        size: 16,
                        color: currentState == 2
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
