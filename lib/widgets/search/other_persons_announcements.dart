// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/services/auth.dart';

class OtherPersonsAnnouncements extends StatefulWidget {
  const OtherPersonsAnnouncements({super.key});

  @override
  _OtherPersonsAnnouncementsState createState() =>
      _OtherPersonsAnnouncementsState();
}

class _OtherPersonsAnnouncementsState extends State<OtherPersonsAnnouncements> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true; // Show progress indicator
    });

    Provider.of<UserProfileState>(context, listen: false);
    final currentUser = _authService.getCurrentUserId();

    try {
      // Fetch all users
      final users = await _authService.fetchAllUsersWithDocuments();
      List<Map<String, dynamic>> announcements = [];

      // Iterate over users and fetch their announcements
      for (var user in users) {
        if (user['uid'] != currentUser) {
          final userAnnouncements = await _fetchUserAnnouncements(user['uid']);
          if (userAnnouncements.isNotEmpty) {
            for (var announcement in userAnnouncements) {
              announcements.add({
                'user': user['firestoreData'],
                'announcement': announcement,
              });
            }
          }
        }
      }

      announcements.sort((a, b) {
        final dateA = DateTime.parse(a['announcement']['createdAt']);
        final dateB = DateTime.parse(b['announcement']['createdAt']);
        return dateB.compareTo(dateA); // Newest first
      });

      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading announcements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserAnnouncements(
      String userId) async {
    try {
      final announcements = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('user_announcements')
          .get();
      return announcements.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error fetching announcements: $e');
      return [];
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

    return Container(
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
          Row(
            children: [
              // User's profile image with rounded corners and custom black stroke
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    21.0), // Same radius for image and stroke
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.customBlack, width: 3),
                    borderRadius:
                        BorderRadius.circular(21.0), // Same radius for stroke
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(18.0), // Same radius for image
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
              // User and title section with fixed height
              Expanded(
                child: Container(
                  height: 74, // Set the fixed height to match the profile image
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: AppColors.customBlack, width: 3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the content vertically
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
          const SizedBox(height: 10),
          // Centered Announcement text section
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
                announcementText,
                textAlign: TextAlign.left, // Text itself left-aligned
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
          // Time ago and distance section, bold and centered with Poppins font
          Center(
            child: Text(
              '$timeAgo • 0.0 km', // Distance can be added here
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_announcements.isEmpty) {
      return const Center(
        child: Text(
          "No announcements available.",
          style: TextStyle(color: AppColors.customBlack, fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.only(
            top: 0, left: 20, right: 20), // Remove top padding
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          return _buildAnnouncementCard(_announcements[index]);
        },
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
