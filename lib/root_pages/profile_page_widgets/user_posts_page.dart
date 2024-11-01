// user_posts_page.dart

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons_posts.dart'; // Import PostCard

class UserPostsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> posts;
  final int initialIndex;

  const UserPostsPage({
    Key? key,
    required this.user,
    required this.posts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Wait for the build to complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calculate the offset to scroll to
      double offset =
          widget.initialIndex * 500.0; // Approximate height of each post
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final posts = widget.posts;

    return Scaffold(
      backgroundColor: AppColors.bg, // Use your preferred background color
      appBar: AppBar(
        title: const Text(
          'Posts',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.customBlack,
          ),
        ),
        backgroundColor: AppColors.bg,
        elevation: 0.0, // Remove shadow
        scrolledUnderElevation: 0.0, // Prevent darkening on scroll
        surfaceTintColor:
            Colors.transparent, // Keep the background color consistent
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 30.0,
            color: AppColors.customBlack,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(
            top: 16.0, left: 20, right: 20), // Add top padding
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            user: user,
            post: posts[index],
            showUserProfile: false,
          );
        },
      ),
    );
  }
}
