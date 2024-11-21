// profile_info_sections.dart

// ignore_for_file: use_super_parameters

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

  const ShoutSection({
    Key? key,
    required this.announcementTitle,
    required this.announcementText,
    required this.createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timeAgo = calculateTimeAgo(createdAt);

    return _buildInfoContainer(
      shoutPadding: true,
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
                    borderRadius: BorderRadius.circular(16.0),
                    side: const BorderSide(
                      color: AppColors.customBlack,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
            ],
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
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.customBlack, width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Image load error'));
                      },
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

class SavedPostsSection extends StatelessWidget {
  final List<Map<String, dynamic>> savedPosts;
  final Function(int) onPostSelected;

  const SavedPostsSection({
    Key? key,
    required this.savedPosts,
    required this.onPostSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoHeader(
            icon: Icons.bookmark_rounded,
            title: 'Saved Posts',
          ),
          const SizedBox(height: 8.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedPosts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Three images per row
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemBuilder: (context, index) {
              final post = savedPosts[index]['post'];
              final images = List<String>.from(post['images'] ?? []);
              final imageUrl = images.isNotEmpty
                  ? images[0]
                  : UserProfileState.placeholderImageUrl;

              return GestureDetector(
                onTap: () {
                  onPostSelected(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.customBlack, width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Image load error'));
                      },
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
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: !shoutPadding
        ? const EdgeInsets.all(12.0)
        : const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(18.0),
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
