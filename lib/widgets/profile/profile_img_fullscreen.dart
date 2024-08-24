import 'package:doggymatch_flutter/colors.dart';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.asset(
                  widget.images[index],
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
