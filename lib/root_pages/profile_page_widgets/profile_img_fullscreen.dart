import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ValueChanged<int> onImageChanged;

  const FullScreenImageView({
    super.key,
    required this.images,
    this.initialIndex = 0,
    required this.onImageChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late int _currentIndex;
  late PageController _pageController;
  late List<String> _filteredImages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Filter out the placeholder image if there are other images
    _filteredImages = widget.images
        .where((image) => image != UserProfileState.placeholderImageUrl)
        .toList();

    // If no real images exist, use the placeholder image
    if (_filteredImages.isEmpty) {
      _filteredImages = [UserProfileState.placeholderImageUrl];
    }

    // Initialize the PageController with the initial index
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _filteredImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onImageChanged(index); // Notify parent about the change
            },
            itemBuilder: (context, index) {
              final imageUrl = _filteredImages[index];
              final isNetworkImage =
                  imageUrl.startsWith('http') || imageUrl.startsWith('https');

              return Center(
                child: isNetworkImage
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
              );
            },
          ),
          Positioned(
            top: 40.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: _buildImageIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_filteredImages.length, (index) {
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
            color: Colors.white.withOpacity(_currentIndex == index ? 1.0 : 0.5),
          ),
        );
      }),
    );
  }
}
