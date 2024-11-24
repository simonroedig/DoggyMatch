// profile_info_sections.dart

// ignore_for_file: use_super_parameters

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/announcement_dialogs.dart';
import 'package:doggymatch_flutter/services/announcement_service.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';

class UserInfoSection extends StatelessWidget {
  final UserProfile profile;
  final bool clickedOnOtherUser;
  final double distance;
  final String lastOnline;

  const UserInfoSection(
      {Key? key,
      required this.profile,
      required this.clickedOnOtherUser,
      required this.distance,
      required this.lastOnline})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.person_rounded,
            text: profile.userName,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.access_time,
            text: '${profile.userAge}',
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            text: profile.location,
          ),
          if (clickedOnOtherUser) ...[
            const SizedBox(height: 8.0),
            _buildInfoRow(
              icon: Icons.social_distance_rounded,
              text: '${distance.toStringAsFixed(1)} km',
            ),
          ],
          if (clickedOnOtherUser) ...[
            const SizedBox(height: 8.0),
            _buildInfoRow(
              icon: Icons.circle_rounded,
              text: '$lastOnline ago',
            ),
          ],
        ],
      ),
    );
  }
}

class DogInfoSection extends StatelessWidget {
  final UserProfile profile;

  const DogInfoSection({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.pets_rounded,
            text: profile.dogName ?? '',
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: CupertinoIcons.heart_circle,
            text: profile.dogBreed ?? '',
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.access_time,
            text: profile.dogAge ?? '',
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  final UserProfile profile;

  const AboutSection({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoHeader(
            icon: Icons.info_outline_rounded,
            title: 'About',
          ),
          const SizedBox(height: 8.0),
          Text(
            profile.aboutText,
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
}

class ShoutSection extends StatelessWidget {
  final String announcementTitle;
  final String announcementText;
  final DateTime createdAt;
  final bool
      isOwnProfile; // New parameter to indicate if it's the user's own profile

  const ShoutSection({
    Key? key,
    required this.announcementTitle,
    required this.announcementText,
    required this.createdAt,
    required this.isOwnProfile, // Accept the parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timeAgo = calculateTimeAgo(createdAt);

    return _buildInfoContainer(
      // shout padding true if isOwnProfile is true otherwise false
      shoutPadding: isOwnProfile ? true : false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Align text and icon at edges
            children: [
              const _InfoHeader(
                icon: Icons.campaign,
                title: 'Current Shout',
              ),
              if (isOwnProfile) // Show kebab menu only for own profile
                Transform.translate(
                  offset: const Offset(
                      14.0, 0.0), // Move the icon further to the right
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero, // Remove extra padding
                    constraints:
                        const BoxConstraints(), // Prevent internal spacing
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.customBlack,
                    ),
                    onSelected: (String value) async {
                      if (value == 'delete') {
                        bool confirmed = await AnnouncementDialogs
                            .showDeleteShoutConfirmationDialog(context);
                        if (confirmed) {
                          AnnouncementService announcementService =
                              AnnouncementService();
                          await announcementService.deleteAnnouncement();
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: AppColors.customRed,
                            ),
                          ),
                        ),
                      ),
                    ],
                    offset: const Offset(-10, 40),
                    color: AppColors.bg,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(UIConstants.popUpRadius),
                      side: const BorderSide(
                        color: AppColors.customBlack,
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: isOwnProfile
                ? 0.0
                : 10.0, // Adjust height based on isOwnProfile
          ),
          Text(
            announcementTitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.customBlack,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            announcementText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.customBlack,
            ),
          ),
          const SizedBox(height: 8.0),
          Center(
            child: Text(
              timeAgo,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostsSection extends StatelessWidget {
  final List<Map<String, dynamic>> userPosts;
  final Function(int) onPostSelected;

  const PostsSection({
    Key? key,
    required this.userPosts,
    required this.onPostSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoHeader(
            icon: Icons.photo_library_rounded,
            title: 'Posts',
          ),
          const SizedBox(height: 8.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userPosts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Three images per row
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemBuilder: (context, index) {
              final post = userPosts[index];
              final images = List<String>.from(post['images'] ?? []);
              final imageUrl = images.isNotEmpty
                  ? images[0]
                  : UserProfileState.placeholderImageUrl;

              return GestureDetector(
                onTap: () {
                  onPostSelected(index);
                },
                // small post images preview
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.customBlack, width: 3),
                    borderRadius:
                        BorderRadius.circular(UIConstants.innerInnerRadius),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        UIConstants.innerInnerRadiusClipped),
                    child: Stack(
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('-'));
                          },
                        ),
                        // Image indicator for multiple images
                        if (images.length > 1)
                          Positioned(
                            bottom: 4.0,
                            right: 4.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: AppColors.customBlack,
                                borderRadius: BorderRadius.circular(UIConstants
                                    .innerInnerRadiusClipped), // Adjust radius
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.collections,
                                    color: AppColors.bg,
                                    size: 14.0,
                                  ),
                                  const SizedBox(width: 2.0),
                                  Text(
                                    '${images.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Shared Components
Widget _buildInfoContainer({required Widget child, bool shoutPadding = false}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5.0),
    padding: !shoutPadding
        ? const EdgeInsets.all(10.0)
        : const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(UIConstants.innerRadius),
      border: Border.all(
        color: AppColors.customBlack,
        width: 3.0,
      ),
    ),
    child: child,
  );
}

Widget _buildInfoRow({required IconData icon, required String text}) {
  return Row(
    children: [
      Icon(icon, color: AppColors.customBlack),
      const SizedBox(width: 8.0),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.customBlack,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
    ],
  );
}

class _InfoHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _InfoHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.customBlack),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.customBlack,
          ),
        ),
      ],
    );
  }
}
