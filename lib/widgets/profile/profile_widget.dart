import 'package:doggymatch_flutter/widgets/profile/profile_edit_all.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_image_stack.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_info_sections.dart';
import 'package:doggymatch_flutter/widgets/profile_chat/profile_chat.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class ProfileWidget extends StatefulWidget {
  final UserProfile profile;
  final bool clickedOnOtherUser;
  final double distance;
  final String lastOnline;
  final bool startInChat;

  const ProfileWidget({
    super.key,
    required this.profile,
    required this.clickedOnOtherUser,
    required this.distance,
    required this.lastOnline,
    this.startInChat = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool _isInChat = false;

  @override
  void initState() {
    super.initState();
    _isInChat = widget.startInChat; // Initialize with the provided parameter
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg, // Set the background color here
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal:
                17.0), // Adjust padding to create space on the left and right
        child: _buildProfileContainer(
          child: Column(
            children: [
              if (!_isInChat)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ProfileImageStack(
                            profile: widget.profile,
                            clickedOnOtherUser: widget.clickedOnOtherUser),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              UserInfoSection(
                                  profile: widget.profile,
                                  clickedOnOtherUser: widget.clickedOnOtherUser,
                                  distance: widget.distance,
                                  lastOnline: widget.lastOnline),
                              if (widget.profile.isDogOwner)
                                DogInfoSection(profile: widget.profile),
                              AboutSection(profile: widget.profile),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ProfileChat(
                    otherUserProfile: widget.profile,
                    onHeaderTapped: () {
                      setState(() {
                        _isInChat = false; // Go back to profile view
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color:
            _isInChat ? AppColors.brownLightest : widget.profile.profileColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppColors.customBlack,
          width: 3.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21.0),
        child: child,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              widget.profile.isDogOwner
                  ? Icons.pets_rounded
                  : Icons.person_rounded,
              color: AppColors.customBlack,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.profile.isDogOwner ? 'Dog Owner' : 'Dog Sitter',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.customBlack,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (widget.clickedOnOtherUser) ...[
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded,
                    color: AppColors.customBlack),
                onPressed: () {
                  // Handle add friend action here
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_rounded,
                    color: AppColors.customBlack),
                onPressed: () {
                  // Handle save action here
                },
              ),
            ],
            IconButton(
              icon: Icon(
                _isInChat
                    ? Icons.arrow_back_rounded
                    : widget.clickedOnOtherUser
                        ? Icons.message_rounded
                        : Icons.border_color_rounded,
                color: AppColors.customBlack,
              ),
              onPressed: () {
                setState(() {
                  if (_isInChat) {
                    _isInChat = false; // Go back to profile view
                  } else {
                    if (widget.clickedOnOtherUser) {
                      _isInChat = true; // Switch to chat view
                    } else {
                      _openEditProfileDialog(
                          context); // Open edit profile if not on another user's profile
                    }
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  void _openEditProfileDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileImageEdit(
          profile: widget.profile,
        ),
      ),
    );
  }
}
