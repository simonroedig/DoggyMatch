// other_persons_posts.dart
// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:developer' as developer;
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/notifiers/filter_notifier.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/posts_dialogs.dart';
import 'package:doggymatch_flutter/services/post_service.dart';
import 'package:doggymatch_flutter/services/friends_service.dart'; // Add this import
import 'package:doggymatch_flutter/shared_helper/icon_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/services/auth_service.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/post_img_fullscreen.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:doggymatch_flutter/root_pages/search_page_widgets/ENUM_post_filter_option.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/shared_helper/autoscrolling.dart';

class OtherPersonsPosts extends StatefulWidget {
  final PostFilterOption selectedOption;
  final Function(UserProfile, String, String, bool) onProfileSelected;

  const OtherPersonsPosts({
    Key? key,
    required this.selectedOption,
    required this.onProfileSelected,
  }) : super(key: key);

  @override
  _OtherPersonsPostsState createState() => _OtherPersonsPostsState();
}

class _OtherPersonsPostsState extends State<OtherPersonsPosts> {
  final AuthService _authService = AuthService();
  final _authProfile = ProfileService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];

  late FilterNotifier _filterNotifier;

  final iconHelpers = IconHelpers();

  @override
  void initState() {
    super.initState();
    _filterNotifier = Provider.of<FilterNotifier>(context, listen: false);
    _filterNotifier.addListener(_onFilterChanged);

    loadPosts();
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    _filterNotifier.removeListener(_onFilterChanged);
    log('Widget Disposed: $runtimeType');
    super.dispose();
  }

  void _onFilterChanged() {
    // Reload posts whenever the filter changes
    loadPosts();
  }

  @override
  void didUpdateWidget(covariant OtherPersonsPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOption != oldWidget.selectedOption) {
      loadPosts();
    }
  }

  Future<void> loadPosts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final String? currentUserId = _authService.getCurrentUserId();

    List<Map<String, dynamic>> posts = [];

    try {
      switch (widget.selectedOption) {
        case PostFilterOption.allPosts:
          await _loadAllPosts(currentUserId, userProfileState, posts);
          break;
        case PostFilterOption.friendsPosts:
          await _loadFriendsPosts(currentUserId, posts);
          break;
        case PostFilterOption.likedPosts:
          await _loadLikedPosts(currentUserId, posts);
          break;
        case PostFilterOption.savedPosts:
          await _loadSavedPosts(currentUserId, posts);
          break;
      }

      // Sort posts by createdAt
      posts.sort((a, b) {
        final dateA = DateTime.parse(a['post']['createdAt']);
        final dateB = DateTime.parse(b['post']['createdAt']);
        return dateB.compareTo(dateA); // Newest first
      });

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAllPosts(
      String? currentUserId,
      UserProfileState userProfileState,
      List<Map<String, dynamic>> posts) async {
    List<Map<String, dynamic>> users =
        await _authProfile.fetchAllUsersWithinFilter(
      userProfileState.userProfile.filterLookingForDogOwner,
      userProfileState.userProfile.filterLookingForDogSitter,
      userProfileState.userProfile.filterDistance,
      userProfileState.userProfile.latitude,
      userProfileState.userProfile.longitude,
      userProfileState.userProfile.filterLastOnline,
    );
    users = users.where((user) => user['uid'] != currentUserId).toList();

    for (var user in users) {
      final userPosts = await _fetchUserPosts(user['uid']);
      if (userPosts.isNotEmpty) {
        for (var post in userPosts) {
          posts.add({
            'user': user['firestoreData'],
            'post': post,
          });
        }
      }
    }
  }

  // ignore: unused_element
  Future<void> _loadOwnPosts(
      String? currentUserId, List<Map<String, dynamic>> posts) async {
    final currentUserProfile = await _authProfile.fetchUserProfile();
    if (currentUserProfile != null) {
      final userPosts = await _fetchUserPosts(currentUserProfile.uid);
      if (userPosts.isNotEmpty) {
        for (var post in userPosts) {
          posts.add({
            'user': currentUserProfile.toMap(),
            'post': post,
          });
        }
      }
    }
  }

  Future<void> _loadFriendsPosts(
      String? currentUserId, List<Map<String, dynamic>> posts) async {
    if (currentUserId == null) return;

    final friendsService = FriendsService();

    // Fetch all friends' profiles
    final friends = await friendsService.fetchAllFriends();

    for (var friend in friends) {
      final friendId = friend['uid'];
      final friendProfileData = friend['firestoreData'];

      // Fetch posts for each friend
      final friendPosts = await _fetchUserPosts(friendId);

      if (friendPosts.isNotEmpty) {
        for (var post in friendPosts) {
          posts.add({
            'user': friendProfileData,
            'post': post,
          });
        }
      }
    }
  }

  Future<void> _loadLikedPosts(
      String? currentUserId, List<Map<String, dynamic>> posts) async {
    if (currentUserId == null) return;

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    final data = currentUserDoc.data();
    if (data != null && data['likedPosts'] != null) {
      final List<dynamic> likedPostIds = data['likedPosts'];
      for (String postId in likedPostIds) {
        // Extract postOwnerId from postId
        final parts = postId.split('|');
        if (parts.length != 2) continue;
        final postOwnerId = parts[0];

        // Fetch the post data
        final postDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(postOwnerId)
            .collection('user_posts')
            .doc(postId)
            .get();
        if (postDoc.exists) {
          final postData = postDoc.data();
          if (postData != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(postOwnerId)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              if (userData != null) {
                posts.add({
                  'user': userData,
                  'post': postData,
                });
              }
            }
          }
        }
      }
    }
  }

  Future<void> _loadSavedPosts(
      String? currentUserId, List<Map<String, dynamic>> posts) async {
    if (currentUserId == null) return;

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    final data = currentUserDoc.data();
    if (data != null && data['savedPosts'] != null) {
      final List<dynamic> savedPostIds = data['savedPosts'];
      for (String postId in savedPostIds) {
        // Extract postOwnerId from postId
        final parts = postId.split('|');
        if (parts.length != 2) continue;
        final postOwnerId = parts[0];

        // Fetch the post data
        final postDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(postOwnerId)
            .collection('user_posts')
            .doc(postId)
            .get();
        if (postDoc.exists) {
          final postData = postDoc.data();
          if (postData != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(postOwnerId)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              if (userData != null) {
                posts.add({
                  'user': userData,
                  'post': postData,
                });
              }
            }
          }
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserPosts(String userId) async {
    try {
      final posts = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('user_posts')
          .get();
      return posts.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      developer.log('Error fetching posts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      String noPostsMessage;
      switch (widget.selectedOption) {
        case PostFilterOption.friendsPosts:
          noPostsMessage = 'You have not created any posts yet.';
          break;
        case PostFilterOption.allPosts:
          noPostsMessage = 'No posts found.';
          break;
        case PostFilterOption.likedPosts:
          noPostsMessage = 'You have not liked any posts yet.';
          break;
        case PostFilterOption.savedPosts:
          noPostsMessage = 'You have not saved any posts yet.';
          break;
      }
      return Center(
        child: Text(
          noPostsMessage,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.0,
            color: AppColors.customBlack,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPosts, // Call loadPosts when pulled down
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: PostCard(
              user: _posts[index]['user'],
              post: _posts[index]['post'],
              onProfileSelected: widget.onProfileSelected,
            ),
          );
        },
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> post;
  final Function(UserProfile, String, String, bool)? onProfileSelected;
  final bool fromSingleUserPostPage;

  const PostCard({
    Key? key,
    required this.user,
    required this.post,
    this.onProfileSelected,
    this.fromSingleUserPostPage = false,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  bool _isLiked = false;
  int _likesCount = 0;
  bool _isPostSaved = false;

  final iconHelpers = IconHelpers();
  final _authProfile = ProfileService();

  @override
  void initState() {
    super.initState();

    final currentUserId = _authService.getCurrentUserId();
    final likes = widget.post['likes'] ?? [];
    final postId = widget.post['postId'] ?? '';

    _isLiked = likes.contains(currentUserId);
    _likesCount = likes.length;

    _checkIfPostIsSaved(postId);
  }

  Future<void> _checkIfPostIsSaved(String postId) async {
    final String? currentUserId = _authService.getCurrentUserId();
    if (currentUserId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final data = userDoc.data();
      if (data != null && data['savedPosts'] != null) {
        final savedPosts = Set<String>.from(data['savedPosts']);
        if (mounted) {
          setState(() {
            _isPostSaved = savedPosts.contains(postId);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isPostSaved = false;
          });
        }
      }
    } catch (e) {
      developer.log('Error fetching saved posts: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    log('Widget Disposed: $runtimeType');
    super.dispose();
  }

  void _openCommentsOverlay(
      String postOwnerId,
      String postId,
      Color profileColor,
      VoidCallback onCommentsUpdated,
      Function(UserProfile, String, String, bool)? onProfileSelected) {
    // Modify here

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UIConstants.outerRadius),
                  topRight: Radius.circular(UIConstants.outerRadius),
                ),
              ),
              child: _CommentsOverlay(
                postOwnerId: postOwnerId,
                postId: postId,
                onCommentsUpdated: onCommentsUpdated,
                profileColor: profileColor,
                onProfileSelected: onProfileSelected, // Pass it here
                fromSingleUserPostPage: widget.fromSingleUserPostPage,
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserStatus(String userId) async {
    bool isProfileSaved = await _isProfileSaved(userId);
    String friendStatus = await iconHelpers.determineFriendStatus(userId);
    return {
      'isProfileSaved': isProfileSaved,
      'friendStatus': friendStatus,
    };
  }

  Future<bool> _isProfileSaved(String userId) async {
    return await _authProfile.isProfileSaved(userId);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final post = widget.post;

    final DateTime createdAt = DateTime.parse(post['createdAt']);
    final String timeAgo = calculateLastOnlineLong(createdAt);

    // Get the current user's ID
    final String? currentUserId = _authService.getCurrentUserId();

    // Determine if the post is from the current user
    final bool isOwnPost = currentUserId == user['uid'];

    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final mainUserLatitude = userProfileState.userProfile.latitude;
    final mainUserLongitude = userProfileState.userProfile.longitude;

    final distance = calculateDistance(
      mainUserLatitude,
      mainUserLongitude,
      user['latitude'].toDouble(),
      user['longitude'].toDouble(),
    ).toStringAsFixed(1);

    final profileColor = Color(user['profileColor'] ?? 0xFFFFFFFF);
    final userName = user['userName'] ?? '';
    final isDogOwner = user['isDogOwner'] == true;
    final dogName = user['dogName'] ?? '';
    final postDescription = post['postDescription'] ?? '';
    final postImages = List<String>.from(post['images'] ?? []);
    final String postOwner = post['postOwner'] ?? '';
    final String postId = post['postId'] ?? '';
    final int commentsCount = post['commentsCount'] ?? 0;

    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserStatus(user['uid']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // Or a loading placeholder
        }

        // Extract isProfileSaved and friendStatus from the snapshot
        bool isProfileSaved = snapshot.data!['isProfileSaved'];
        String friendStatus = snapshot.data!['friendStatus'];

        return GestureDetector(
          onTap: () async {
            if (!isOwnPost && widget.onProfileSelected != null) {
              UserProfile selectedProfile = UserProfile(
                uid: user['uid'],
                email: user['email'],
                userName: user['userName'],
                dogName: user['dogName'],
                dogBreed: user['dogBreed'],
                dogAge: user['dogAge'],
                isDogOwner: user['isDogOwner'],
                images: List<String>.from(user['images']),
                profileColor: profileColor,
                aboutText: user['aboutText'],
                location: user['location'],
                latitude: user['latitude'].toDouble(),
                longitude: user['longitude'].toDouble(),
                filterDistance: user['filterDistance'],
                birthday: user['birthday'] != null
                    ? DateTime.parse(user['birthday'])
                    : null,
                lastOnline: user['lastOnline'] != null
                    ? DateTime.parse(user['lastOnline'])
                    : null,
                filterLastOnline: user['filterLastOnline'] ?? 3,
              );
              final lastOnline =
                  calculateLastOnlineLong(selectedProfile.lastOnline);

              widget.onProfileSelected!(
                  selectedProfile, distance, lastOnline, isProfileSaved);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            padding: const EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: profileColor,
              borderRadius: BorderRadius.circular(UIConstants.outerRadius),
              border: Border.all(color: AppColors.customBlack, width: 3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  UIConstants.innerRadius),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.customBlack, width: 3),
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.innerRadius),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.innerRadiusClipped),
                                  child: Image.network(
                                    user['images'][0],
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            // Friend Icon
                            if (friendStatus != 'none')
                              Positioned(
                                bottom: -4,
                                left: -4,
                                child: iconHelpers.buildFriendStatusIcon(
                                    friendStatus, profileColor, 3),
                              ),
                            // Save Icon (Profile Save Icon)
                            if (isProfileSaved)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: iconHelpers.buildSaveIcon(
                                    true, profileColor, 3, 20),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Container(
                            height: 74,
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(
                                  UIConstants.innerRadius),
                              border: Border.all(
                                  color: AppColors.customBlack, width: 3),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoScrollingRow(
                                  userName: userName,
                                  isDogOwner: isDogOwner,
                                  dogName: dogName,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOwnPost
                                      ? timeAgo
                                      : '$timeAgo • $distance km',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildPostImages(postImages),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius:
                          BorderRadius.circular(UIConstants.innerRadius),
                      border:
                          Border.all(color: AppColors.customBlack, width: 3),
                    ),
                    child: Text(
                      postDescription,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.customBlack,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius:
                        BorderRadius.circular(UIConstants.innerRadius),
                    border: Border.all(color: AppColors.customBlack, width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side icons (heart and comment)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: AppColors.customBlack,
                                ),
                                onPressed: () {
                                  if (currentUserId == null) {
                                    // Handle user not signed in
                                    return;
                                  }
                                  if (mounted) {
                                    setState(() {
                                      _isLiked = !_isLiked;

                                      if (_isLiked) {
                                        // Like the post
                                        _postService.likePost(
                                            postOwner, postId);
                                        _likesCount += 1;
                                      } else {
                                        // Unlike the post
                                        _postService.unlikePost(
                                            postOwner, postId);
                                        _likesCount = _likesCount > 0
                                            ? _likesCount - 1
                                            : 0;
                                      }
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.comment_outlined,
                                  color: AppColors.customBlack,
                                ),
                                onPressed: () {
                                  _openCommentsOverlay(
                                    postOwner,
                                    postId,
                                    profileColor,
                                    () {
                                      if (mounted) {
                                        setState(() {
                                          post['commentsCount'] =
                                              (post['commentsCount'] ?? 0) + 1;
                                        });
                                      }
                                    },
                                    widget.onProfileSelected,
                                  );
                                },
                              ),
                            ],
                          ),
                          // Right side icon (save post and menu)
                          Row(
                            children: [
                              // Save Icon (Post Save Icon)
                              IconButton(
                                icon: Icon(
                                  _isPostSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: AppColors.customBlack,
                                ),
                                onPressed: () {
                                  if (currentUserId == null) {
                                    // Handle user not signed in
                                    return;
                                  }
                                  if (mounted) {
                                    setState(() {
                                      _isPostSaved = !_isPostSaved;

                                      if (_isPostSaved) {
                                        // Save the post
                                        _postService.savePost(postId);
                                      } else {
                                        // Unsave the post
                                        _postService.unsavePost(postId);
                                      }
                                    });
                                  }
                                },
                              ),
                              // Kebab Menu Icon
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: AppColors.customBlack),
                                onSelected: (String value) async {
                                  if (value == 'delete') {
                                    bool confirmed = await PostsDialogs
                                        .showDeletePostConfirmationDialog(
                                            context);
                                    if (confirmed) {
                                      _postService.deletePost(postId);
                                    }
                                  } else if (value == 'report') {
                                    bool confirmed = await PostsDialogs
                                        .showReportPostConfirmationDialog(
                                            context,
                                            user['userName'] ?? 'User');
                                    if (confirmed) {
                                      // Add logic for reporting the post
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  if (isOwnPost)
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Center(
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.customRed,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!isOwnPost)
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Center(
                                        child: Text(
                                          'Report',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.customRed,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                                offset: const Offset(0, 40),
                                color: AppColors.bg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.innerRadius),
                                  side: const BorderSide(
                                    color: AppColors.customBlack,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Separator line
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        height: 3.0,
                        color: AppColors.customBlack,
                      ),
                      // Likes row
                      GestureDetector(
                        onTap: () {
                          // Open likes overlay
                          _openLikesOverlay(
                            postOwner,
                            postId,
                            profileColor,
                            widget.onProfileSelected,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                color: AppColors.customBlack,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _likesCount == 0
                                    ? 'no likes yet'
                                    : _likesCount == 1
                                        ? 'liked by 1 person'
                                        : 'liked by $_likesCount people',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.customBlack,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.open_in_browser_rounded,
                                color: AppColors.customBlack,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Separator line
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        height: 3.0,
                        color: AppColors.customBlack,
                      ),
                      // Comments text
                      GestureDetector(
                        onTap: () {
                          // Open comments overlay
                          _openCommentsOverlay(
                            postOwner,
                            postId,
                            profileColor,
                            () {
                              if (mounted) {
                                setState(() {
                                  // Update the commentsCount in the post data
                                  post['commentsCount'] =
                                      (post['commentsCount'] ?? 0) + 1;
                                });
                              }
                            },
                            widget.onProfileSelected,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.comment_outlined,
                                    size: 14,
                                    color: AppColors.customBlack,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    commentsCount == 0
                                        ? 'Write the first comment'
                                        : commentsCount == 1
                                            ? 'View $commentsCount comment'
                                            : 'View all $commentsCount comments',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.customBlack,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.open_in_browser_rounded,
                                    size: 16,
                                    color: AppColors.customBlack,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openLikesOverlay(
    String postOwnerId,
    String postId,
    Color profileColor,
    Function(UserProfile, String, String, bool)? onProfileSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UIConstants.outerRadius),
                  topRight: Radius.circular(UIConstants.outerRadius),
                ),
              ),
              child: _LikesOverlay(
                postOwnerId: postOwnerId,
                postId: postId,
                profileColor: profileColor,
                onProfileSelected: onProfileSelected, // Pass it here
                fromSingleUserPostPage:
                    widget.fromSingleUserPostPage, // Add this line
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostImages(List<String> postImages) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.customBlack, width: 3),
        borderRadius: BorderRadius.circular(UIConstants.innerRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.innerRadiusClipped),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.0, // Set aspect ratio to 1:1
              child: PageView.builder(
                controller: _pageController,
                itemCount: postImages.isEmpty ? 1 : postImages.length,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  final imageUrl = postImages.isNotEmpty
                      ? postImages[index]
                      : UserProfileState.placeholderImageUrl;

                  return GestureDetector(
                    onTap: () => _openFullScreenImageView(context, postImages),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Image load error'));
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 8.0,
              left: 0,
              right: 0,
              child: _buildImageIndicator(postImages),
            ),
          ],
        ),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostFullScreenImageView(
          images: images.isNotEmpty
              ? images
              : [UserProfileState.placeholderImageUrl],
          initialIndex: _currentImageIndex, // Pass current index
          onImageChanged: (newIndex) {
            if (mounted) {
              setState(() {
                _currentImageIndex = newIndex;
                _pageController
                    .jumpToPage(newIndex); // Sync view after fullscreen
              });
            }
          },
        ),
      ),
    );
  }
}

class _CommentsOverlay extends StatefulWidget {
  final String postOwnerId;
  final String postId;
  final VoidCallback onCommentsUpdated;
  final Color profileColor;
  final Function(UserProfile, String, String, bool)?
      onProfileSelected; // Add this line
  final bool fromSingleUserPostPage; // Add this line

  const _CommentsOverlay({
    Key? key,
    required this.postOwnerId,
    required this.postId,
    required this.onCommentsUpdated,
    required this.profileColor,
    this.onProfileSelected,
    required this.fromSingleUserPostPage, // Add this line
  }) : super(key: key);

  @override
  __CommentsOverlayState createState() => __CommentsOverlayState();
}

class __CommentsOverlayState extends State<_CommentsOverlay>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  final TextEditingController _commentController = TextEditingController();
  final PostService _postService = PostService();
  final Map<String, Map<String, dynamic>> _userProfiles = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, ScrollController> _scrollControllers = {};
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_handleTextChange);
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.removeListener(_handleTextChange);
    _commentController.dispose();
    log('Widget Disposed: $runtimeType');

    // Dispose all animation and scroll controllers
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {
        _hasText = _commentController.text.trim().isNotEmpty;
      });
    }
  }

  Future<void> _fetchComments() async {
    final comments =
        await _postService.getComments(widget.postOwnerId, widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments.reversed.toList();
        _isLoadingComments = false;
      });
    }
  }

  String _calculateTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _fetchUserProfile(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            _userProfiles[userId] = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      developer.log('Error fetching user profile: $e');
    }
  }

  Widget _buildCommentItem(Map<String, dynamic> commentData) {
    final String userId = commentData['userId'] ?? '';
    final String commentText = commentData['commentText'] ?? '';
    final DateTime createdAt = DateTime.parse(commentData['createdAt']);
    final String timeAgo = _calculateTimeAgo(createdAt);

    // For profile picture and user data, we need to fetch the user's profile data
    String profileImageUrl = UserProfileState.placeholderImageUrl;
    String userName = 'Anonymous';
    bool isDogOwner = false;
    String dogName = '';

    if (_userProfiles.containsKey(userId)) {
      final userProfile = _userProfiles[userId]!;
      final images = List<String>.from(userProfile['images'] ?? []);
      if (images.isNotEmpty) {
        profileImageUrl = images[0];
      }
      userName = userProfile['userName'] ?? 'Anonymous';
      isDogOwner = userProfile['isDogOwner'] ?? false;
      dogName = userProfile['dogName'] ?? '';
    } else {
      // Fetch user profile
      _fetchUserProfile(userId);
    }

    // Create unique keys for controllers based on userId and comment timestamp
    final String controllerKey = '$userId${createdAt.toIso8601String()}';

    // Initialize controllers if they don't exist
    if (!_scrollControllers.containsKey(controllerKey)) {
      _scrollControllers[controllerKey] = ScrollController();
      _animationControllers[controllerKey] = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      );

      final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
          .animate(_animationControllers[controllerKey]!);

      animation.addListener(() {
        if (_scrollControllers[controllerKey]!.hasClients) {
          _scrollControllers[controllerKey]!.jumpTo(animation.value *
              _scrollControllers[controllerKey]!.position.maxScrollExtent);
        }
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_scrollControllers[controllerKey]!.hasClients) {
              _scrollControllers[controllerKey]!.jumpTo(0);
              _animationControllers[controllerKey]!.forward(from: 0.0);
            }
          });
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationControllers[controllerKey]!.forward();
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
        children: [
          // Profile picture with GestureDetector
          GestureDetector(
            onTap: () async {
              final String? currentUserId = AuthService().getCurrentUserId();
              if (widget.fromSingleUserPostPage &&
                  userId != currentUserId &&
                  userId != widget.postOwnerId) {
                // Navigate to search_page.dart when fromSingleUserPostPage is true
                // Step 1: Navigate back to the MainScreen first.
                developer.log('Navigating back to MainScreen');
                // Set the userId in UserProfileState
                final userProfileState =
                    Provider.of<UserProfileState>(context, listen: false);

                /*
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', // Replace with your main screen route
                  (Route<dynamic> route) => false,
                );
                  */
                // use this, to allow user to go back:
                Navigator.of(context).pushNamed('/');

                // Navigator.pop(context);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  int currentIndex = userProfileState.currentIndex;
                  developer.log(currentIndex.toString());
                  if (currentIndex == 2) {
                    //currentIndex = 0;
                  }
                  if (mounted) {
                    userProfileState.updateCurrentIndex(
                        currentIndex); // Set index to SearchPage
                    userProfileState.setUserIdToOpen(userId);
                    userProfileState.openedProfileViaSubpage();
                  }
                });
              } else if (userId != currentUserId &&
                  widget.onProfileSelected != null &&
                  _userProfiles.containsKey(userId) &&
                  userId != widget.postOwnerId) {
                final userProfileData = _userProfiles[userId]!;

                UserProfile selectedProfile = UserProfile(
                  uid: userProfileData['uid'],
                  email: userProfileData['email'],
                  userName: userProfileData['userName'],
                  dogName: userProfileData['dogName'],
                  dogBreed: userProfileData['dogBreed'],
                  dogAge: userProfileData['dogAge'],
                  isDogOwner: userProfileData['isDogOwner'],
                  images: List<String>.from(userProfileData['images']),
                  profileColor:
                      Color(userProfileData['profileColor'] ?? 0xFFFFFFFF),
                  aboutText: userProfileData['aboutText'],
                  location: userProfileData['location'],
                  latitude: userProfileData['latitude'].toDouble(),
                  longitude: userProfileData['longitude'].toDouble(),
                  filterDistance: userProfileData['filterDistance'],
                  birthday: userProfileData['birthday'] != null
                      ? DateTime.parse(userProfileData['birthday'])
                      : null,
                  lastOnline: userProfileData['lastOnline'] != null
                      ? DateTime.parse(userProfileData['lastOnline'])
                      : null,
                  filterLastOnline: userProfileData['filterLastOnline'] ?? 3,
                );

                // Calculate distance and lastOnline
                final userProfileState =
                    Provider.of<UserProfileState>(context, listen: false);
                final mainUserLatitude = userProfileState.userProfile.latitude;
                final mainUserLongitude =
                    userProfileState.userProfile.longitude;

                final distance = calculateDistance(
                  mainUserLatitude,
                  mainUserLongitude,
                  userProfileData['latitude'].toDouble(),
                  userProfileData['longitude'].toDouble(),
                ).toStringAsFixed(1);

                final lastOnline =
                    calculateLastOnlineLong(selectedProfile.lastOnline);

                // Fetch the actual saved status
                final profileService = ProfileService();
                final isSaved = await profileService.isProfileSaved(userId);

                widget.onProfileSelected!(
                  selectedProfile,
                  distance,
                  lastOnline,
                  isSaved, // Adjust saved status as needed
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.customBlack, width: 3),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(profileImageUrl),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Auto-scrolling username row
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollControllers[controllerKey],
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                size: 20, color: AppColors.customBlack),
                            const SizedBox(width: 4),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.customBlack,
                              ),
                            ),
                            if (isDogOwner) ...[
                              const SizedBox(width: 4),
                              const Text(
                                " • ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.customBlack,
                                ),
                              ),
                              const Icon(
                                Icons.pets_rounded,
                                size: 18,
                                color: AppColors.customBlack,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dogName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.customBlack,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0.0),
                // Comment text
                Text(
                  commentText,
                  style: const TextStyle(
                    color: AppColors.customBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      // Add comment
      _postService
          .addComment(widget.postOwnerId, widget.postId, commentText)
          .then((_) {
        _commentController.clear();
        // Fetch comments again
        _fetchComments();
        // Call the callback to update comments count
        widget.onCommentsUpdated();
      });
    }
  }

  Widget _buildCommentInputArea(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Comment input field and character counter
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, top: 14.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(UIConstants.innerRadius),
                  border: Border.all(
                    color: AppColors.customBlack,
                    width: 3.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        maxLength: 250,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                          hintText: 'Write a comment...',
                          hintStyle: TextStyle(color: AppColors.grey),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        style: const TextStyle(color: AppColors.customBlack),
                        minLines: 1,
                        maxLines: 3, // Limit max lines to prevent overflow
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color:
                            _hasText ? AppColors.customBlack : AppColors.grey,
                      ),
                      onPressed: _hasText ? _sendComment : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0, bottom: 8.0),
              child: Text(
                '${_commentController.text.length}/250',
                style: const TextStyle(
                  color: AppColors.customBlack,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              color: widget.profileColor,
              border: Border.all(color: AppColors.customBlack, width: 3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(UIConstants.outerRadius),
                topRight: Radius.circular(UIConstants.outerRadius),
              ),
            ),
            child: Column(
              children: [
                // Draggable notch at the top
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.customBlack,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Comments list
                Expanded(
                  child: _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                          ? const Center(
                              child: Text(
                                "No comments yet, be the first one",
                                style: TextStyle(color: AppColors.customBlack),
                              ),
                            )
                          : ListView.builder(
                              reverse: false,
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return _buildCommentItem(comment);
                              },
                            ),
                ),
                // Input field and character counter
                _buildCommentInputArea(context),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LikesOverlay extends StatefulWidget {
  final String postOwnerId;
  final String postId;
  final Color profileColor;
  final Function(UserProfile, String, String, bool)? onProfileSelected;
  final bool fromSingleUserPostPage; // Add this line

  const _LikesOverlay({
    Key? key,
    required this.postOwnerId,
    required this.postId,
    required this.profileColor,
    this.onProfileSelected,
    required this.fromSingleUserPostPage, // Add this line
  }) : super(key: key);

  @override
  __LikesOverlayState createState() => __LikesOverlayState();
}

class __LikesOverlayState extends State<_LikesOverlay>
    with TickerProviderStateMixin {
  List<String> _likes = [];
  bool _isLoadingLikes = true;
  final Map<String, Map<String, dynamic>> _userProfiles = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, ScrollController> _scrollControllers = {};
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  @override
  void dispose() {
    // Dispose all animation and scroll controllers
    log('Widget Disposed: $runtimeType');
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    log('Widget Disposed: $runtimeType');
    super.dispose();
  }

  Future<void> _fetchLikes() async {
    final likes =
        await _postService.getPostLikes(widget.postOwnerId, widget.postId);
    if (mounted) {
      setState(() {
        _likes = likes!;
        _isLoadingLikes = false;
      });
    }
  }

  void _fetchUserProfile(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            _userProfiles[userId] = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      developer.log('Error fetching user profile: $e');
    }
  }

  Widget _buildLikeItem(String userId) {
    // For profile picture and user data, we need to fetch the user's profile data
    String profileImageUrl = UserProfileState.placeholderImageUrl;
    String userName = 'Anonymous';
    bool isDogOwner = false;
    String dogName = '';

    if (_userProfiles.containsKey(userId)) {
      final userProfile = _userProfiles[userId]!;
      final images = List<String>.from(userProfile['images'] ?? []);
      if (images.isNotEmpty) {
        profileImageUrl = images[0];
      }
      userName = userProfile['userName'] ?? 'Anonymous';
      isDogOwner = userProfile['isDogOwner'] ?? false;
      dogName = userProfile['dogName'] ?? '';
    } else {
      // Fetch user profile
      _fetchUserProfile(userId);
    }

    // Create unique keys for controllers based on userId
    final String controllerKey = userId;

    // Initialize controllers if they don't exist
    if (!_scrollControllers.containsKey(controllerKey)) {
      _scrollControllers[controllerKey] = ScrollController();
      _animationControllers[controllerKey] = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      );

      final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
          .animate(_animationControllers[controllerKey]!);

      animation.addListener(() {
        if (_scrollControllers[controllerKey]!.hasClients) {
          _scrollControllers[controllerKey]!.jumpTo(animation.value *
              _scrollControllers[controllerKey]!.position.maxScrollExtent);
        }
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_scrollControllers[controllerKey]!.hasClients) {
              _scrollControllers[controllerKey]!.jumpTo(0);
              _animationControllers[controllerKey]!.forward(from: 0.0);
            }
          });
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationControllers[controllerKey]!.forward();
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center the content vertically
        children: [
          // Profile picture with GestureDetector
          GestureDetector(
            onTap: () async {
              final String? currentUserId = AuthService().getCurrentUserId();
              if (widget.fromSingleUserPostPage &&
                  userId != currentUserId &&
                  userId != widget.postOwnerId) {
                // Navigate to the main screen and open the profile
                developer.log('Navigating back to MainScreen');
                final userProfileState =
                    Provider.of<UserProfileState>(context, listen: false);

                /*
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', // Replace with your main screen route
                  (Route<dynamic> route) => false,
                );
                  */
                // use this, to allow user to go back:
                Navigator.of(context).pushNamed('/');

                // Navigator.pop(context);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  int currentIndex = userProfileState.currentIndex;
                  developer.log(currentIndex.toString());
                  if (currentIndex == 2) {
                    //currentIndex = 0;
                  }
                  if (mounted) {
                    userProfileState.updateCurrentIndex(
                        currentIndex); // Set index to SearchPage
                    userProfileState.setUserIdToOpen(userId);
                    userProfileState.openedProfileViaSubpage();
                  }
                });
              } else if (userId != currentUserId &&
                  widget.onProfileSelected != null &&
                  _userProfiles.containsKey(userId) &&
                  userId != widget.postOwnerId) {
                final userProfileData = _userProfiles[userId]!;

                UserProfile selectedProfile = UserProfile(
                  uid: userProfileData['uid'],
                  email: userProfileData['email'],
                  userName: userProfileData['userName'],
                  dogName: userProfileData['dogName'],
                  dogBreed: userProfileData['dogBreed'],
                  dogAge: userProfileData['dogAge'],
                  isDogOwner: userProfileData['isDogOwner'],
                  images: List<String>.from(userProfileData['images']),
                  profileColor:
                      Color(userProfileData['profileColor'] ?? 0xFFFFFFFF),
                  aboutText: userProfileData['aboutText'],
                  location: userProfileData['location'],
                  latitude: userProfileData['latitude'].toDouble(),
                  longitude: userProfileData['longitude'].toDouble(),
                  filterDistance: userProfileData['filterDistance'],
                  birthday: userProfileData['birthday'] != null
                      ? DateTime.parse(userProfileData['birthday'])
                      : null,
                  lastOnline: userProfileData['lastOnline'] != null
                      ? DateTime.parse(userProfileData['lastOnline'])
                      : null,
                  filterLastOnline: userProfileData['filterLastOnline'] ?? 3,
                );

                // Calculate distance and lastOnline
                final userProfileState =
                    Provider.of<UserProfileState>(context, listen: false);
                final mainUserLatitude = userProfileState.userProfile.latitude;
                final mainUserLongitude =
                    userProfileState.userProfile.longitude;

                final distance = calculateDistance(
                  mainUserLatitude,
                  mainUserLongitude,
                  userProfileData['latitude'].toDouble(),
                  userProfileData['longitude'].toDouble(),
                ).toStringAsFixed(1);

                final lastOnline =
                    calculateLastOnlineLong(selectedProfile.lastOnline);

                // Fetch the actual saved status
                final profileService = ProfileService();
                final isSaved = await profileService.isProfileSaved(userId);

                widget.onProfileSelected!(
                  selectedProfile,
                  distance,
                  lastOnline,
                  isSaved, // Adjust saved status as needed
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.customBlack, width: 2),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(profileImageUrl),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Username and dog name with auto-scrolling
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollControllers[controllerKey],
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(Icons.person_rounded,
                      size: 20, color: AppColors.customBlack),
                  const SizedBox(width: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.customBlack,
                    ),
                  ),
                  if (isDogOwner) ...[
                    const SizedBox(width: 4),
                    const Text(
                      " • ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.customBlack,
                      ),
                    ),
                    const Icon(
                      Icons.pets_rounded,
                      size: 18,
                      color: AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dogName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.customBlack,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              color: widget.profileColor,
              border: Border.all(color: AppColors.customBlack, width: 3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(UIConstants.outerRadius),
                topRight: Radius.circular(UIConstants.outerRadius),
              ),
            ),
            child: Column(
              children: [
                // Draggable notch at the top
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.customBlack,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Likes list
                Expanded(
                  child: _isLoadingLikes
                      ? const Center(child: CircularProgressIndicator())
                      : _likes.isEmpty
                          ? const Center(
                              child: Text(
                                "No likes yet, be the first one",
                                style: TextStyle(color: AppColors.customBlack),
                              ),
                            )
                          : ListView.builder(
                              reverse: false,
                              itemCount: _likes.length,
                              itemBuilder: (context, index) {
                                final userId = _likes[index];
                                return _buildLikeItem(userId);
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
