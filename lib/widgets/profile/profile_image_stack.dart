import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_img_fullscreen.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class ProfileImageStack extends StatefulWidget {
  final UserProfile profile;

  const ProfileImageStack({super.key, required this.profile});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileImageStackState createState() => _ProfileImageStackState();
}

class _ProfileImageStackState extends State<ProfileImageStack> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.profile.images
        .where((image) => image != UserProfileState.placeholderImageUrl)
        .toList();

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openFullScreenImageView(context, images),
          child: _buildProfileImageSlider(images),
        ),
        Positioned(
          bottom: 8.0,
          left: 0,
          right: 0,
          child: _buildImageIndicator(images),
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
        /*
        Positioned(
          top: 2.0,
          right: 2.0,
          child: IconButton(
            icon: const Icon(Icons.edit_square,
                color: AppColors.customBlack, size: 20.0),
            onPressed: () => _openEditImagePage(context),
          ),
        ),
        */
      ],
    );
  }

  Widget _buildProfileImageSlider(List<String> images) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: images.isEmpty ? 1 : images.length,
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = images.isNotEmpty
              ? images[index]
              : UserProfileState.placeholderImageUrl;

          // Check if the image is a URL or an asset path
          final isNetworkImage =
              imageUrl.startsWith('http') || imageUrl.startsWith('https');

          return isNetworkImage
              ? Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
        },
      ),
    );
  }

  Widget _buildImageIndicator(List<String> images) {
    final int imageCount = images.isEmpty ? 1 : images.length;

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

  void _openFullScreenImageView(BuildContext context, List<String> images) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FullScreenImageView(
        images:
            images.isNotEmpty ? images : [UserProfileState.placeholderImageUrl],
        initialIndex: _currentImageIndex,
      ),
    ));
  }

  /*
  void _openEditImagePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileImageEdit(
          profile: widget.profile,
        ),
      ),
    );
  }
  */
}
