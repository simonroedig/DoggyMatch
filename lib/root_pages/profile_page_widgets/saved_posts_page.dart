import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons_posts.dart'; // Import PostCard

class SavedPostsPage extends StatefulWidget {
  final List<Map<String, dynamic>> savedPosts;
  final int initialIndex;

  const SavedPostsPage({
    Key? key,
    required this.savedPosts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _SavedPostsPageState createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.savedPosts.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final postData = widget.savedPosts[index];
          return PostCard(
            user: postData['user'],
            post: postData['post'],
            showUserProfile: true,
            onProfileSelected: (UserProfile selectedProfile, String distance,
                String lastOnline, bool isSaved) {
              // Handle profile selection if needed
            },
          );
        },
      ),
    );
  }
}
