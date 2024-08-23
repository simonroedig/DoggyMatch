import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/profile_img_fullscreen.dart';

class ProfileWidget extends StatefulWidget {
  final Profile profile;

  const ProfileWidget({super.key, required this.profile});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: widget.profile.profileColor,
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
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _openFullScreenImageView(context);
                          },
                          child: _buildProfileImageSlider(),
                        ),
                        Positioned(
                          bottom: 8.0,
                          left: 0,
                          right: 0,
                          child: _buildImageIndicator(),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    widget.profile is DogSitterProfile
                                        ? Icons
                                            .person_rounded // Icon for Dog Sitter
                                        : Icons.pets, // Icon for Dog Owner
                                    color: AppColors.customBlack,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    widget.profile is DogSitterProfile
                                        ? 'Dog Sitter'
                                        : 'Dog Owner',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.customBlack,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.border_color_rounded,
                                    color: AppColors.customBlack),
                                onPressed: () {
                                  // Edit functionality here
                                },
                              ),
                            ],
                          ),
                          _buildUserInfoSection(),
                          if (widget.profile is DogOwnerProfile)
                            _buildDogInfoSection(
                                widget.profile as DogOwnerProfile),
                          _buildAboutSection(),
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

  Widget _buildProfileImageSlider() {
    return SizedBox(
      height: 250, // Adjust the height as needed
      child: PageView.builder(
        itemCount:
            widget.profile.images.isEmpty ? 1 : widget.profile.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = widget.profile.images.isNotEmpty
              ? widget.profile.images[index]
              : 'assets/icons/placeholder.png'; // Placeholder image path

          return Image.asset(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildImageIndicator() {
    final int imageCount =
        widget.profile.images.isEmpty ? 1 : widget.profile.images.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(imageCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.customBlack,
              width: 2.0,
            ),
            shape: BoxShape.circle,
            color: Colors.white
                .withOpacity(_currentImageIndex == index ? 1.0 : 0.5),
          ),
        );
      }),
    );
  }

  void _openFullScreenImageView(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FullScreenImageView(
        images: widget.profile.images.isNotEmpty
            ? widget.profile.images
            : ['assets/icons/placeholder.png'], // Pass images or placeholder
        initialIndex: _currentImageIndex,
      ),
    ));
  }

  Widget _buildUserInfoSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_rounded, color: AppColors.customBlack),
              const SizedBox(width: 8.0),
              Text(
                widget.profile.userName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.customBlack),
              const SizedBox(width: 8.0),
              Text(
                '${widget.profile.userAge}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.customBlack),
              const SizedBox(width: 8.0),
              Text(
                'About',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.profile.aboutText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.customBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDogInfoSection(DogOwnerProfile dogOwnerProfile) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets_rounded, color: AppColors.customBlack),
              const SizedBox(width: 8.0),
              Text(
                dogOwnerProfile.dogName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(CupertinoIcons.heart_circle,
                  color: AppColors.customBlack),
              const SizedBox(width: 8.0),
              Text(
                dogOwnerProfile.dogBreed,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.customBlack),
              const SizedBox(width: 8.0),
              Text(
                '${dogOwnerProfile.dogAge} years old',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
