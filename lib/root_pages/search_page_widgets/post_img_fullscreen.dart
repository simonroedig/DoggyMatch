import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class PostFullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ValueChanged<int> onImageChanged;

  const PostFullScreenImageView({
    super.key,
    required this.images,
    this.initialIndex = 0,
    required this.onImageChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PostFullScreenImageViewState createState() =>
      _PostFullScreenImageViewState();
}

class _PostFullScreenImageViewState extends State<PostFullScreenImageView> {
  late int _currentIndex;
  late PageController _fullscreenPageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Initialize a separate PageController for the fullscreen view
    _fullscreenPageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // Dispose of the controller when done to avoid memory leaks
    _fullscreenPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _fullscreenPageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onImageChanged(index); // Synchronize with the parent
            },
            itemBuilder: (context, index) {
              final imageUrl = widget.images[index];
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
            top: 10.0,
            right: 10.0,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0), // Increase tap area
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
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
      children: List.generate(widget.images.length, (index) {
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
