import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:flutter/cupertino.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.accent1,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppColors.customBlack,
          width: 3.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Image with bottom stroke
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24.0),
                          ),
                          child: Image.asset(
                            'assets/icons/zz.png',
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3.0,
                            color: AppColors.customBlack,
                          ),
                        ),
                      ],
                    ),
                    // Content below the image
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.person,
                                      color: AppColors.customBlack),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Dog Sitter',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.customBlack,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(CupertinoIcons.pencil_circle,
                                    color: AppColors.customBlack),
                                onPressed: () {
                                  // Edit functionality here
                                },
                              ),
                            ],
                          ),
                          // First Section (Name and Age)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: AppColors.customBlack,
                                width: 3.0,
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: AppColors.customBlack),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Andi',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: AppColors.customBlack,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: AppColors.customBlack),
                                    SizedBox(width: 8.0),
                                    Text(
                                      '26',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: AppColors.customBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Second Section (Description)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: AppColors.customBlack,
                                width: 3.0,
                              ),
                            ),
                            child: const Text(
                              'My name is Andi. I am a student in Munich looking for some Dogs I can go for a walk with. Due to my student situation, I am very flexible and also available on the weekends and offer overnight stays for your dog. Feel free to write me! Love you and goodbye haha. I am out, see ya.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppColors.customBlack,
                              ),
                            ),
                          ),
                        ],
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
