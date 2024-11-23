// profile_posts_section.dart

// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons_posts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart'; // Import PostCard

class UserPostsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> posts;
  final int initialIndex;
  final bool isSavedPosts;

  const UserPostsPage({
    Key? key,
    required this.user,
    required this.posts,
    required this.initialIndex,
    this.isSavedPosts = false,
  }) : super(key: key);

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(index: widget.initialIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final posts = widget.posts;

    return Scaffold(
      backgroundColor: AppColors.bg,
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
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 30.0,
            color: AppColors.customBlack,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        padding:
            const EdgeInsets.only(top: 0.0, left: 20, right: 20, bottom: 10),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> post;
          Map<String, dynamic> postUser;

          if (widget.isSavedPosts) {
            final postData = posts[index];
            postUser = postData['user'];
            post = postData['post'];
          } else {
            postUser = user;
            post = posts[index];
          }

          return PostCard(
            user: postUser,
            post: post,
            fromSingleUserPostPage: true,
          );
        },
      ),
    );
  }
}
