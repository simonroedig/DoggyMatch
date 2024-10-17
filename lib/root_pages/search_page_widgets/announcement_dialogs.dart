// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/services/announcement_service.dart';

class AnnouncementDialogs {
  static void showDismissConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(
              color: AppColors.customBlack,
              width: 3.0,
            ),
          ),
          title: const Center(
            child: Text(
              'Dismiss Announcement?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.customBlack,
              ),
            ),
          ),
          content: const Text(
            'You have unsaved changes in your announcement. Do you want to dismiss it?',
            style: TextStyle(
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
                      Navigator.of(context).pop();
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
                  ElevatedButton(
                    onPressed: () {
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
                      'No, Stay',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: AppColors.customBlack,
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

  static void showCreateConfirmationDialog(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController announcementController,
    DateTime? selectedDate,
    bool showForever,
    bool hasAnnouncement, // Added hasAnnouncement parameter
  ) {
    // Determine the dialog title based on whether an announcement exists
    String dialogTitle = hasAnnouncement
        ? 'Create Shout\nand Replace Old Shout?'
        : 'Create Shout?';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(
              color: AppColors.customBlack,
              width: 3.0,
            ),
          ),
          title: Center(
            child: Text(
              dialogTitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.customBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Please review your shout details below. You can delete the shout later anytime.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Shout Title:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.customBlack),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  titleController.text,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.customBlack,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Shout Text:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.customBlack),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    announcementController.text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.customBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Show Until:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                showForever
                    ? 'Show Forever'
                    : (selectedDate != null
                        ? DateFormat.yMd().format(selectedDate)
                        : 'No date selected'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
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
                      'No, Edit',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: AppColors.customBlack,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      AnnouncementService announcementService =
                          AnnouncementService();
                      await announcementService.createAnnouncement(
                        announcementTitle: titleController.text,
                        announcementText: announcementController.text,
                        showUntilDate: selectedDate,
                        showForever: showForever,
                      );
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pop(); // Close the page after creation
                      showSuccessDialog(context);
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

  static void showSuccessDialog(BuildContext context) {
    // Declare dialogContext as nullable
    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context; // Assign the dialog's context
        return AlertDialog(
          backgroundColor: AppColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(
              color: AppColors.customBlack,
              width: 3.0,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.customGreen,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                'Shout successfully created!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.customBlack,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      // Ensure dialogContext is not null before using it
      if (dialogContext != null && Navigator.of(dialogContext!).mounted) {
        Navigator.of(dialogContext!).pop();
      }
    });
  }
}
