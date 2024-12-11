// user_posts_content.dart

import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons_posts.dart';

class UserPostsContent extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> posts;
  final int initialIndex;
  final bool isSavedPosts;
  final Function(UserProfile, String, String, bool)? onProfileSelected;

  const UserPostsContent({
    Key? key,
    required this.user,
    required this.posts,
    required this.initialIndex,
    this.isSavedPosts = false,
    this.onProfileSelected,
  }) : super(key: key);

  @override
  _UserPostsContentState createState() => _UserPostsContentState();
}

class _UserPostsContentState extends State<UserPostsContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double offset = widget.initialIndex * 500.0; // Approximate height
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final posts = widget.posts;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16.0, left: 20, right: 20),
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
          showUserProfile: true,
          onProfileSelected: widget.onProfileSelected,
        );
      },
    );
  }
}
