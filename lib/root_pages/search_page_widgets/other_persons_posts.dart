import 'dart:developer' as developer;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/post_img_fullscreen.dart';
import 'package:flutter/services.dart'; // Add this import

class OtherPersonsPosts extends StatefulWidget {
  final bool showOnlyCurrentUser;
  final Function(UserProfile, String, String, bool) onProfileSelected;

  const OtherPersonsPosts({
    super.key,
    required this.showOnlyCurrentUser,
    required this.onProfileSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OtherPersonsPostsState createState() => _OtherPersonsPostsState();
}

class _OtherPersonsPostsState extends State<OtherPersonsPosts> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  List<PageController> _pageControllers = []; // List of PageControllers
  List<int> _currentImageIndexes =
      []; // Track the current image index for each post
  final Map<String, bool> _postLikes = {};
  final Map<String, int> _postLikesCount = {}; // New Map to track likes count

  // Variables for saved posts
  Set<String> _savedPosts = {}; // To store saved post identifiers
  final Map<String, bool> _postSaves = {}; // To track save state of posts

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    // Dispose all page controllers
    for (var controller in _pageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OtherPersonsPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showOnlyCurrentUser != oldWidget.showOnlyCurrentUser) {
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

    List<Map<String, dynamic>> users = [];
    List<Map<String, dynamic>> posts = [];

    try {
      if (!widget.showOnlyCurrentUser) {
        users = await _authService.fetchAllUsersWithinFilter(
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
      } else {
        final currentUserProfile = await _authService.fetchUserProfile();
        if (currentUserProfile != null) {
          users = [currentUserProfile.toMap()];
          final userPosts = await _fetchUserPosts(users[0]['uid']);
          if (userPosts.isNotEmpty) {
            for (var post in userPosts) {
              posts.add({
                'user': users[0],
                'post': post,
              });
            }
          }
        }
      }

      posts.sort((a, b) {
        final dateA = DateTime.parse(a['post']['createdAt']);
        final dateB = DateTime.parse(b['post']['createdAt']);
        return dateB.compareTo(dateA); // Newest first
      });

      // Fetch saved posts before updating state
      await _fetchSavedPosts();

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
          _pageControllers =
              List.generate(_posts.length, (index) => PageController());
          _currentImageIndexes = List.generate(
              _posts.length, (index) => 0); // Initialize current indexes
        });
      }
    } catch (e) {
      developer.log('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _fetchSavedPosts() async {
    final String? currentUserId = _authService.getCurrentUserId();
    if (currentUserId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final data = userDoc.data();
      if (data != null && data['savedPosts'] != null) {
        _savedPosts = Set<String>.from(data['savedPosts']);
      } else {
        _savedPosts = {};
      }
    } catch (e) {
      developer.log('Error fetching saved posts: $e');
    }
  }

  Widget _buildPostImages(List<String> postImages, int postIndex) {
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
                controller: _pageControllers[postIndex],
                itemCount: postImages.isEmpty ? 1 : postImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndexes[postIndex] = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = postImages.isNotEmpty
                      ? postImages[index]
                      : UserProfileState.placeholderImageUrl;

                  return GestureDetector(
                    onTap: () => _openFullScreenImageView(
                        context, postImages, postIndex),
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
              child: _buildImageIndicator(postImages, postIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageIndicator(List<String> images, int postIndex) {
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
            color: Colors.white.withOpacity(
                _currentImageIndexes[postIndex] == index ? 1.0 : 0.5),
          ),
        );
      }),
    );
  }

  void _openFullScreenImageView(
      BuildContext context, List<String> images, int postIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostFullScreenImageView(
          images: images.isNotEmpty
              ? images
              : [UserProfileState.placeholderImageUrl],
          initialIndex: _currentImageIndexes[postIndex], // Pass current index
          onImageChanged: (newIndex) {
            setState(() {
              _currentImageIndexes[postIndex] = newIndex;
              _pageControllers[postIndex]
                  .jumpToPage(newIndex); // Sync view after fullscreen
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text:
                'No posts found 😔\n\nAdjust your filter settings\nand spread the word about ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.0,
              fontWeight: FontWeight.normal,
              color: AppColors.customBlack,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'DoggyMatch',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' 🐶❤️',
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(
            _posts[index], index); // Pass index to differentiate posts
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> postData, int postIndex) {
    final user = postData['user'];
    final post = postData['post'];
    final DateTime createdAt = DateTime.parse(post['createdAt']);
    final String timeAgo = _calculateTimeAgo(createdAt);
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
    final List<dynamic> likes = post['likes'] ?? [];
    final String postOwner = post['postOwner'] ?? '';
    final String postId = post['postId'] ?? '';
    final int commentsCount = post['commentsCount'] ?? 0;

    final currentUserId = _authService.getCurrentUserId();

    // Initialize _postLikes and _postLikesCount if not already set
    if (!_postLikes.containsKey(postId)) {
      _postLikes[postId] = likes.contains(currentUserId);
    }
    if (!_postLikesCount.containsKey(postId)) {
      _postLikesCount[postId] = likes.length;
    }

    // Initialize _postSaves
    if (!_postSaves.containsKey(postId)) {
      _postSaves[postId] = _savedPosts.contains(postId);
    }

    return GestureDetector(
      onTap: () {
        if (!widget.showOnlyCurrentUser) {
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
          widget.onProfileSelected(
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
                              widget.showOnlyCurrentUser
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
            _buildPostImages(postImages,
                postIndex), // Display post images with rounded edges
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
            // Updated section for icons and likes
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
                              _postLikes[postId] ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.customBlack,
                            ),
                            onPressed: () {
                              if (currentUserId == null) {
                                // Handle user not signed in
                                return;
                              }
                              setState(() {
                                _postLikes[postId] = !_postLikes[postId]!;

                                if (_postLikes[postId] == true) {
                                  // Like the post
                                  PostService().likePost(postOwner, postId);
                                  _postLikesCount[postId] =
                                      (_postLikesCount[postId] ?? 0) + 1;
                                } else {
                                  // Unlike the post
                                  PostService().unlikePost(postOwner, postId);
                                  _postLikesCount[postId] =
                                      (_postLikesCount[postId]! > 0)
                                          ? _postLikesCount[postId]! - 1
                                          : 0;
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
                          _postSaves[postId] ?? false
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: AppColors.customBlack,
                        ),
                        onPressed: () {
                          if (currentUserId == null) {
                            // Handle user not signed in
                            return;
                          }
                          setState(() {
                            _postSaves[postId] = !_postSaves[postId]!;

                            if (_postSaves[postId] == true) {
                              // Save the post
                              PostService().savePost(postId);
                              _savedPosts.add(postId);
                            } else {
                              // Unsave the post
                              PostService().unsavePost(postId);
                              _savedPosts.remove(postId);
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
                      _postLikesCount[postId] == 0
                          ? 'no likes yet'
                          : _postLikesCount[postId] == 1
                              ? 'liked by 1 person'
                              : 'liked by ${_postLikesCount[postId]} people',
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
                      child: Text(
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
                  profileColor: profileColor),
            );
          },
        );
      },
    );
  }
}

class _CommentsOverlay extends StatefulWidget {
  final String postOwnerId;
  final String postId;
  final VoidCallback onCommentsUpdated;
  final Color profileColor;

  // ignore: use_super_parameters
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
                const SizedBox(height: 4.0),
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
    // Get the height of the keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: widget.profileColor,
        border: Border.all(color: AppColors.customBlack, width: 3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18.0), // Rounded top-left corner
          topRight: Radius.circular(18.0), // Rounded top-right corner
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18.0), // Match the container's border radius
          topRight: Radius.circular(18.0),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
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
              // Divider
              // Comment input field
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
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
                              hintText: 'Write a comment..',
                              hintStyle: TextStyle(color: AppColors.grey),
                              border: InputBorder.none,
                              counterText: '', // Hide built-in counter
                            ),
                            style:
                                const TextStyle(color: AppColors.customBlack),
                            minLines:
                                1, // Minimum number of lines for the text field
                            maxLines:
                                5, // Maximum number of lines for the text field
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
              // Character counter
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 24.0, bottom: 8.0), // Adjust padding as needed
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
    );
  }
}

class _AutoScrollingRow extends StatefulWidget {
  final String userName;
  final bool isDogOwner;
  final String dogName;

  // ignore: use_super_parameters
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
