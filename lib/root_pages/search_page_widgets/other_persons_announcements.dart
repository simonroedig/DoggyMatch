// file: other_persons_announcements.dart

import 'dart:developer' as developer;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/announcement_dialogs.dart';
import 'package:doggymatch_flutter/services/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/notifiers/filter_notifier.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/shouts_filter_option.dart';

class OtherPersonsAnnouncements extends StatefulWidget {
  final ShoutsFilterOption selectedOption;

  final Function(UserProfile, String, String, bool) onProfileSelected;

  const OtherPersonsAnnouncements({
    Key? key,
    required this.selectedOption,
    required this.onProfileSelected,
  }) : super(key: key);

  @override
  _OtherPersonsAnnouncementsState createState() =>
      _OtherPersonsAnnouncementsState();
}

class _OtherPersonsAnnouncementsState extends State<OtherPersonsAnnouncements> {
  final AuthService _authService = AuthService();
  String? _currentUserId;

  bool _isLoading = true;

  List<Map<String, dynamic>> _announcements = [];

  late FilterNotifier _filterNotifier;

  @override
  void initState() {
    super.initState();

    _filterNotifier = Provider.of<FilterNotifier>(context, listen: false);

    _filterNotifier.addListener(_loadFilteredUsersAnnouncements);
    _currentUserId = _authService.getCurrentUserId();

    _loadFilteredUsersAnnouncements();
  }

  @override
  void didUpdateWidget(covariant OtherPersonsAnnouncements oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedOption != oldWidget.selectedOption) {
      // Reload announcements when the filter option changes

      _loadFilteredUsersAnnouncements();
    }
  }

  @override
  void dispose() {
    _filterNotifier.removeListener(_loadFilteredUsersAnnouncements);

    super.dispose();
  }

  Future<void> _loadFilteredUsersAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.selectedOption == ShoutsFilterOption.friendsShouts) {
      // Load friends' announcements
      await _loadFriendsAnnouncements();
    } else {
      // Existing logic for other shouts (e.g., allShouts)
      final userProfileState =
          Provider.of<UserProfileState>(context, listen: false);
      //final String? currentUserId = _authService.getCurrentUserId();

      List<Map<String, dynamic>> users = [];
      List<Map<String, dynamic>> announcements = [];

      try {
        if (widget.selectedOption == ShoutsFilterOption.allShouts) {
          users = await _authService.fetchAllUsersWithinFilter(
            userProfileState.userProfile.filterLookingForDogOwner,
            userProfileState.userProfile.filterLookingForDogSitter,
            userProfileState.userProfile.filterDistance,
            userProfileState.userProfile.latitude,
            userProfileState.userProfile.longitude,
            userProfileState.userProfile.filterLastOnline,
          );

          for (var user in users) {
            final userAnnouncements =
                await _fetchUserAnnouncements(user['uid']);
            for (var announcement in userAnnouncements) {
              announcements.add({
                'user': user['firestoreData'],
                'announcement': announcement,
              });
            }
          }
        }

        // Sort announcements by creation date (newest first)
        announcements.sort((a, b) {
          final dateA = DateTime.parse(a['announcement']['createdAt']);
          final dateB = DateTime.parse(b['announcement']['createdAt']);
          return dateB.compareTo(dateA);
        });

        if (mounted) {
          setState(() {
            _announcements = announcements;
            _isLoading = false;
          });
        }
      } catch (e) {
        developer.log('Error loading filtered users and announcements: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFriendsAnnouncements() async {
    final String? currentUserId = _authService.getCurrentUserId();
    List<Map<String, dynamic>> announcements = [];

    if (currentUserId == null) return;

    final friendsService = FriendsService();

    try {
      // Fetch all friends' profiles
      final friends = await friendsService.fetchAllFriends();

      for (var friend in friends) {
        final friendId = friend['uid'];
        final friendProfileData = friend['firestoreData'];

        // Fetch announcements for each friend
        final friendAnnouncements = await _fetchUserAnnouncements(friendId);

        if (friendAnnouncements.isNotEmpty) {
          for (var announcement in friendAnnouncements) {
            announcements.add({
              'user': friendProfileData,
              'announcement': announcement,
            });
          }
        }
      }

      // Sort announcements by creation date (newest first)
      announcements.sort((a, b) {
        final dateA = DateTime.parse(a['announcement']['createdAt']);
        final dateB = DateTime.parse(b['announcement']['createdAt']);
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _announcements = announcements;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading friends announcements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserAnnouncements(
      String userId) async {
    try {
      final announcementsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('user_announcements')
          .get();

      return announcementsSnapshot.docs.map((doc) {
        var data = doc.data();

        data['id'] = doc.id;

        return data;
      }).toList();
    } catch (e) {
      developer.log('Error fetching announcements: $e');

      return [];
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

  Future<bool> _isProfileSaved(String userId) async {
    return await _authService.isProfileSaved(userId);
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcementData) {
    final user = announcementData['user'];
    final announcement = announcementData['announcement'];
    final DateTime createdAt = DateTime.parse(announcement['createdAt']);
    final String timeAgo = _calculateTimeAgo(createdAt);

    final String profileImage =
        user['images'].isNotEmpty ? user['images'][0] : '';
    final Color profileColor = Color(user['profileColor'] ?? 0xFFFFFFFF);
    final bool isDogOwner = user['isDogOwner'] == true;
    final String dogName = user['dogName'] ?? '';
    final String userName = user['userName'] ?? '';
    final String announcementTitle = announcement['announcementTitle'] ?? '';
    final String announcementText = announcement['announcementText'] ?? '';

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

    return FutureBuilder<bool>(
      future: _isProfileSaved(user['uid']),
      builder: (context, snapshot) {
        bool isSaved = snapshot.data ?? false;

        return GestureDetector(
          onTap: () {
            if (user['uid'] != _currentUserId) {
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
                  calculateLastOnline(selectedProfile.lastOnline);

              widget.onProfileSelected(
                  selectedProfile, distance, lastOnline, isSaved);
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
            child: Stack(
              children: [
                Column(
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
                                    profileImage,
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
                                    _AutoScrollingTitleRow(
                                      title: announcementTitle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isSaved)
                          Positioned(
                            top: 3,
                            left: 4,
                            child: Transform.scale(
                              scale: 0.85,
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.bookmark_border_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  Icon(
                                    Icons.bookmark_rounded,
                                    color: AppColors.bg,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(
                              color: AppColors.customBlack, width: 3),
                        ),
                        child: Text(
                          announcementText,
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
                    Center(
                      child: Text(
                        user['uid'] == _currentUserId
                            ? timeAgo
                            : '$timeAgo • $distance km',
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (user['uid'] == _currentUserId)
                  Positioned(
                    bottom: -16,
                    right: -15,
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.customBlack,
                        size: 18,
                      ),
                      onSelected: (String value) {
                        if (value == 'delete') {
                          AnnouncementDialogs.showDeleteAnnouncementDialog(
                            context,
                            announcementTitle,
                            () => _deleteAnnouncement(announcement['id']),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Center(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: AppColors.customBlack,
                              ),
                            ),
                          ),
                        ),
                      ],
                      offset: const Offset(0, 50),
                      color: AppColors.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: const BorderSide(
                          color: AppColors.customBlack,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAnnouncement(String announcementId) async {
    try {
      final currentUserId = _authService.getCurrentUserId();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('user_announcements')
          .doc(announcementId)
          .delete();
      setState(() {
        _loadFilteredUsersAnnouncements();
      });
    } catch (e) {
      developer.log('Error deleting announcement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_announcements.isEmpty) {
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: widget.selectedOption == ShoutsFilterOption.friendsShouts
                ? 'You do not have an active shout \n\nCreate a new one'
                : 'No shouts found 😔\n\nAdjust your filter settings\nand spread the word about ',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.0,
              fontWeight: FontWeight.normal,
              color: AppColors.customBlack,
            ),
            children: <TextSpan>[
              TextSpan(
                text: widget.selectedOption == ShoutsFilterOption.friendsShouts
                    ? ''
                    : 'DoggyMatch',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: ' 🐶❤️',
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFilteredUsersAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          return _buildAnnouncementCard(_announcements[index]);
        },
      ),
    );
  }

  String calculateLastOnline(DateTime? lastOnline) {
    final now = DateTime.now();
    final difference = now.difference(lastOnline!);

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Just now';
    }
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

class _AutoScrollingTitleRow extends StatefulWidget {
  final String title;

  const _AutoScrollingTitleRow({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  __AutoScrollingTitleRowState createState() => __AutoScrollingTitleRowState();
}

class __AutoScrollingTitleRowState extends State<_AutoScrollingTitleRow>
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
      child: Text(
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.customBlack,
        ),
      ),
    );
  }
}
