import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/main/colors.dart'; // Importing the custom colors

class ProfileImageEdit extends StatelessWidget {
  final UserProfile profile;

  const ProfileImageEdit({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg, // Set the background color
      appBar: AppBar(
        backgroundColor: AppColors.bg, // Set the app bar background color
        title: const Text('Edit Profile Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columns
            crossAxisSpacing: 8.0, // spacing between columns
            mainAxisSpacing: 8.0, // spacing between rows
            childAspectRatio: 1, // square cells
          ),
          itemCount: 9, // 3x3 grid
          itemBuilder: (context, index) {
            if (index < profile.images.length) {
              // If the index is within the number of images, show the image with border and rounded corners
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.customBlack, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9.0),
                  child: Image.asset(
                    profile.images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else {
              // If the index is the first empty slot, show the "Add Image" icon with border and rounded corners
              return GestureDetector(
                onTap: () {
                  // Implement the logic to add a new image here
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brownLightest, // Set placeholder color
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        color: AppColors.customBlack,
                        width: 3), // Set border color and width
                  ),
                  child: index == profile.images.length
                      ? const Icon(
                          Icons.add_a_photo,
                          color: AppColors.customBlack,
                        )
                      : null, // Other placeholders remain empty
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
