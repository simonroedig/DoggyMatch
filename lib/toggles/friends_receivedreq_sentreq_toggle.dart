import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class FriendsReceivedReqSentReqToggle extends StatefulWidget {
  final Function(int) onToggle; // Callback for when the toggle changes

  const FriendsReceivedReqSentReqToggle({super.key, required this.onToggle});

  @override
  // ignore: library_private_types_in_public_api
  _FriendsReceivedReqSentReqToggleState createState() =>
      _FriendsReceivedReqSentReqToggleState();
}

class _FriendsReceivedReqSentReqToggleState
    extends State<FriendsReceivedReqSentReqToggle> {
  int currentState = 0; // 0 = Friends, 1 = Received, 2 = Sent

  void toggleSwitch() {
    setState(() {
      currentState = (currentState + 1) % 3; // Cycle through 0 -> 1 -> 2 -> 0
    });
    widget.onToggle(currentState);
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
          border: Border.all(color: AppColors.customBlack, width: 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friends state
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      currentState == 0 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_rounded,
                        size: 24,
                        color: currentState == 0
                            ? AppColors.bg
                            : AppColors.customBlack),
                    Transform.translate(
                      offset: const Offset(-6, -3), // Adjust icon position
                      child: Icon(Icons.check_rounded,
                          size: 16,
                          color: currentState == 0
                              ? AppColors.bg
                              : AppColors.customBlack),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 2,
              color: AppColors.customBlack,
            ),
            // Received state
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      currentState == 1 ? AppColors.customBlack : AppColors.bg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_rounded,
                        size: 24,
                        color: currentState == 1
                            ? AppColors.bg
                            : AppColors.customBlack),
                    Transform.translate(
                      offset: const Offset(-6, -3), // Adjust icon position
                      child: Icon(Icons.call_received_rounded,
                          size: 16,
                          color: currentState == 1
                              ? AppColors.bg
                              : AppColors.customBlack),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 2,
              color: AppColors.customBlack,
            ),
            // Sent state
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      currentState == 2 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_rounded,
                        size: 24,
                        color: currentState == 2
                            ? AppColors.bg
                            : AppColors.customBlack),
                    Transform.translate(
                      offset: const Offset(-6, -3), // Adjust icon position
                      child: Icon(Icons.call_made_rounded,
                          size: 16,
                          color: currentState == 2
                              ? AppColors.bg
                              : AppColors.customBlack),
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
