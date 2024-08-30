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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImageIndex);
  }

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
      ],
    );
  }

  Widget _buildProfileImageSlider(List<String> images) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
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

          final isNetworkImage =
              imageUrl.startsWith('http') || imageUrl.startsWith('https');

          return isNetworkImage
              ? Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Error'),
                    );
                  },
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
        onImageChanged: (newIndex) {
          setState(() {
            _currentImageIndex = newIndex;
            _pageController.jumpToPage(newIndex);
          });
        },
      ),
    ));
  }
}
