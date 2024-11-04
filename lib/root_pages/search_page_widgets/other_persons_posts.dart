// other_persons_posts.dart
// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:developer' as developer;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/services/post_service.dart';
import 'package:doggymatch_flutter/services/friends_service.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/post_img_fullscreen.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:doggymatch_flutter/root_pages/search_page_widgets/post_filter_option.dart';

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
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void didUpdateWidget(covariant OtherPersonsPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOption != oldWidget.selectedOption) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllPosts(
      String? currentUserId,
      UserProfileState userProfileState,
      List<Map<String, dynamic>> posts) async {
    List<Map<String, dynamic>> users =
        await _authService.fetchAllUsersWithinFilter(
      userProfileState.userProfile.filterLookingForDogOwner,
      userProfileState.userProfile.filterLookingForDogSitter,
      userProfileState.userProfile.filterDistance,
      userProfileState.userProfile.latitude,
      userProfileState.userProfile.longitude,
      userProfileState.userProfile.filterLastOnline,
    );
    //users = users.where((user) => user['uid'] != currentUserId).toList();

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
    final currentUserProfile = await _authService.fetchUserProfile();
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
      onRefresh: _loadPosts, // Call _loadPosts when pulled down
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            user: _posts[index]['user'],
            post: _posts[index]['post'],
            onProfileSelected: widget.onProfileSelected,
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

  const PostCard({
    Key? key,
    required this.user,
    required this.post,
    this.onProfileSelected,
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
  bool _isSaved = false;

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
        setState(() {
          _isSaved = savedPosts.contains(postId);
        });
      } else {
        setState(() {
          _isSaved = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching saved posts: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the Earth in kilometers

    final dLat = _deg2rad(lat2 - lat1);

    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in kilometers
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  String calculateLastOnline(DateTime? lastOnline) {
    final now = DateTime.now();

    final difference = now.difference(lastOnline!);

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

  void _openCommentsOverlay(String postOwnerId, String postId,
      Color profileColor, VoidCallback onCommentsUpdated) {
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
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: _CommentsOverlay(
                postOwnerId: postOwnerId,
                postId: postId,
                onCommentsUpdated: onCommentsUpdated,
                profileColor: profileColor,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final post = widget.post;

    final DateTime createdAt = DateTime.parse(post['createdAt']);
    final String timeAgo = _calculateTimeAgo(createdAt);

    // Get the current user's ID
    final String? currentUserId = _authService.getCurrentUserId();

    // Determine if the post is from the current user
    final bool isOwnPost = currentUserId == user['uid'];

    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final mainUserLatitude = userProfileState.userProfile.latitude;
    final mainUserLongitude = userProfileState.userProfile.longitude;

    final distance = _calculateDistance(
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

    return GestureDetector(
      onTap: () {
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
          final lastOnline = calculateLastOnline(selectedProfile.lastOnline);
          widget.onProfileSelected!(
              selectedProfile, distance, lastOnline, false);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: profileColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppColors.customBlack, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.customBlack, width: 3),
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            user['images'][0],
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                        height: 74,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                              color: AppColors.customBlack, width: 3),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AutoScrollingRow(
                              userName: userName,
                              isDogOwner: isDogOwner,
                              dogName: dogName,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOwnPost ? timeAgo : '$timeAgo • $distance km',
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
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: AppColors.customBlack, width: 3),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(color: AppColors.customBlack, width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // *buttonrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side icons (heart and comment)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: AppColors.customBlack,
                            ),
                            onPressed: () {
                              if (currentUserId == null) {
                                // Handle user not signed in
                                return;
                              }
                              setState(() {
                                _isLiked = !_isLiked;

                                if (_isLiked) {
                                  // Like the post
                                  _postService.likePost(postOwner, postId);
                                  _likesCount += 1;
                                } else {
                                  // Unlike the post
                                  _postService.unlikePost(postOwner, postId);
                                  _likesCount =
                                      _likesCount > 0 ? _likesCount - 1 : 0;
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.comment_outlined,
                              color: AppColors.customBlack,
                            ),
                            onPressed: () {
                              // Open comments overlay
                              _openCommentsOverlay(
                                  postOwner, postId, profileColor, () {
                                setState(() {
                                  // Update the commentsCount in the post data
                                  post['commentsCount'] =
                                      (post['commentsCount'] ?? 0) + 1;
                                });
                              });
                            },
                          ),
                        ],
                      ),
                      // Right side icon (save)
                      IconButton(
                        icon: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.customBlack,
                        ),
                        onPressed: () {
                          if (currentUserId == null) {
                            // Handle user not signed in
                            return;
                          }
                          setState(() {
                            _isSaved = !_isSaved;

                            if (_isSaved) {
                              // Save the post
                              _postService.savePost(postId);
                            } else {
                              // Unsave the post
                              _postService.unsavePost(postId);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  // Separator line
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    height: 3.0,
                    color: AppColors.customBlack,
                  ),
                  // New row for likes
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
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
                  ),
                  // Separator line
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    height: 3.0,
                    color: AppColors.customBlack,
                  ),
                  // Comments text
                  GestureDetector(
                    onTap: () {
                      // Open comments overlay
                      _openCommentsOverlay(postOwner, postId, profileColor, () {
                        setState(() {
                          // Update the commentsCount in the post data
                          post['commentsCount'] =
                              (post['commentsCount'] ?? 0) + 1;
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        children: [
                          Text(
                            commentsCount == 0
                                ? 'Write the first comment'
                                : 'View all $commentsCount comments',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: AppColors.customBlack,
                            ),
                          ),
                          const SizedBox(
                              height: 4), // Add extra spacing below comments
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImages(List<String> postImages) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.customBlack, width: 3),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Stack(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: postImages.isEmpty ? 1 : postImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
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
                      height: 200,
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
            setState(() {
              _currentImageIndex = newIndex;
              _pageController
                  .jumpToPage(newIndex); // Sync view after fullscreen
            });
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

  const _CommentsOverlay({
    Key? key,
    required this.postOwnerId,
    required this.postId,
    required this.onCommentsUpdated,
    required this.profileColor,
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
    setState(() {
      _hasText = _commentController.text.trim().isNotEmpty;
    });
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
          // Profile picture
          Container(
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.profileColor,
          border: Border.all(color: AppColors.customBlack, width: 3),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
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
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
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
                // Comment input field and character counter
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 14.0),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.84,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 0.0),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(20.0),
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
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                hintText: 'Write a comment..',
                                hintStyle: TextStyle(color: AppColors.grey),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              style:
                                  const TextStyle(color: AppColors.customBlack),
                              minLines: 1,
                              maxLines: 5,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: _hasText
                                  ? AppColors.customBlack
                                  : AppColors.grey,
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
          ),
        ),
      ),
    );
  }
}

class _AutoScrollingRow extends StatefulWidget {
  final String userName;
  final bool isDogOwner;
  final String dogName;

  const _AutoScrollingRow({
    Key? key,
    required this.userName,
    required this.isDogOwner,
    required this.dogName,
  }) : super(key: key);

  @override
  __AutoScrollingRowState createState() => __AutoScrollingRowState();
}

class __AutoScrollingRowState extends State<_AutoScrollingRow>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_animationController)
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
              _animation.value * _scrollController.position.maxScrollExtent);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
              _animationController.forward(from: 0.0);
            }
          });
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(Icons.person_rounded,
              size: 20, color: AppColors.customBlack),
          const SizedBox(width: 4),
          Text(
            widget.userName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.customBlack,
            ),
          ),
          if (widget.isDogOwner) ...[
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
              widget.dogName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.customBlack,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
