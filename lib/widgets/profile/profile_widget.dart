import 'dart:developer';

import 'package:doggymatch_flutter/widgets/profile/profile_edit_all.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_image_stack.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_info_sections.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class ProfileWidget extends StatefulWidget {
  final UserProfile profile;
  final bool clickedOnOtherUser;
  final double distance;

  const ProfileWidget({
    super.key,
    required this.profile,
    required this.clickedOnOtherUser,
    required this.distance,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildProfileContainer(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileImageStack(profile: widget.profile),
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
                            distance: widget.distance),
                        if (widget.profile.isDogOwner)
                          DogInfoSection(profile: widget.profile),
                        AboutSection(profile: widget.profile),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17.0),
      decoration: BoxDecoration(
        color: widget.profile.profileColor,
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
        IconButton(
          icon: Icon(
            widget.clickedOnOtherUser
                ? Icons.message_rounded
                : Icons.border_color_rounded,
            color: AppColors.customBlack,
          ),
          onPressed: widget.clickedOnOtherUser
              ? _sendMessage
              : () => _openEditProfileDialog(context),
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

  void _sendMessage() {
    // Implement your send message functionality here
    log('Send message button pressed');
  }
}
