import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/services/chat_service.dart';
import 'package:doggymatch_flutter/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

void showDeleteConfirmationDialog(
    BuildContext context, String userName, String userIdToDelete) {
  final chatService =
      ChatService(); // Or use Provider.of<ChatService>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.popUpRadius),
          side: const BorderSide(
            color: AppColors.customBlack,
            width: 3.0,
          ),
        ),
        title: const Center(
          child: Text(
            'Are you sure?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.customBlack,
            ),
          ),
        ),
        content: Text(
          'Deleting this chat will remove all messages between you and $userName. '
          'You can still find each other\'s profiles and send new messages.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.customBlack,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle "No" action
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bg,
                    side: const BorderSide(
                      color: AppColors.customBlack,
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Call your new deleteChatRoom method
                    await chatService.deleteChatRoom(userIdToDelete);

                    // Then close the dialog
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.customBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.bg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void showReportConfirmationDialog(
    BuildContext context, String userName, String reportedUserId) {
  TextEditingController reportController = TextEditingController();
  final reportService = ReportService(); // The class from above

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.popUpRadius),
          side: const BorderSide(
            color: AppColors.customBlack,
            width: 3.0,
          ),
        ),
        title: const Center(
          child: Text(
            'Are you sure?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.customBlack,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reporting $userName will also block the profile for you.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.customBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: reportController,
              decoration: const InputDecoration(
                hintText: '(Optional) Reasons for report..',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.grey,
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle "No" action
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bg,
                    side: const BorderSide(
                      color: AppColors.customBlack,
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String reportText = reportController.text.trim();

                    try {
                      await reportService.reportUser(
                        reportedUserId: reportedUserId,
                        reason: reportText,
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();

                      // Optionally, show a success message/snackbar:
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('User reported and blocked successfully')),
                      // );
                    } catch (e) {
                      // Handle errors (e.g., show a snackbar)
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Something went wrong: $e')),
                      // );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.customRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.bg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
