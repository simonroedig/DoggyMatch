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
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openFullScreenImageView(context),
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
    );
  }

  Widget _buildProfileImageSlider() {
    return SizedBox(
      height: 250,
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
              : 'assets/icons/placeholder.png';

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
            : ['assets/icons/placeholder.png'],
        initialIndex: _currentImageIndex,
      ),
    ));
  }
}
