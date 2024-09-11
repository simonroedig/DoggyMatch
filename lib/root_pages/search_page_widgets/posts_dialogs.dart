import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'dart:developer';

class PostsDialogs {
  static Future<bool> showCreateConfirmationDialog(
    BuildContext context,
    List images,
    TextEditingController descriptionController,
  ) async {
    return await showDialog(
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
              'Create Post?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.customBlack,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Please review your post details below before publishing.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.customBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Images:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.customBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: images.map<Widget>((image) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        // add a stroke
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
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
                    descriptionController.text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.customBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
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
                    onPressed: () {
                      Navigator.of(context).pop(true);
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

  static Future<bool> showDismissConfirmationDialog(
      BuildContext context) async {
    try {
      // Ensure that null is not returned
      return await showDialog<bool>(
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
                'Discard Post?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.customBlack,
                ),
              ),
            ),
            content: const Text(
              'You have unsaved changes in your post. Do you want to discard them?',
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
                        Navigator.of(context)
                            .pop(true); // Returns true when 'Yes' is pressed
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
                        Navigator.of(context).pop(
                            false); // Returns false when 'No, Stay' is pressed
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
      ).then((value) =>
          value ?? false); // If the result is null, return false as fallback
    } catch (e) {
      log('Error showing dialog: $e');
      return false; // Return a default value in case of an error
    }
  }
}
