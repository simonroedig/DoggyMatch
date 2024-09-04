// ignore_for_file: library_private_types_in_public_api, use_super_parameters
// file: other_persons_announcements.dart
import 'dart:developer' as developer;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/pages/notifiers/filter_notifier.dart';

class OtherPersonsAnnouncements extends StatefulWidget {
  final bool isAllAnnouncSelected; // Add a parameter to control display type

  const OtherPersonsAnnouncements(
      {super.key, required this.isAllAnnouncSelected});

  @override
  _OtherPersonsAnnouncementsState createState() =>
      _OtherPersonsAnnouncementsState();
}

class _OtherPersonsAnnouncementsState extends State<OtherPersonsAnnouncements> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _announcements = [];
  late FilterNotifier _filterNotifier; // Add a state variable for the notifier

  @override
  void initState() {
    super.initState();
    _filterNotifier = Provider.of<FilterNotifier>(context, listen: false);
    _filterNotifier.addListener(_loadFilteredUsersAnnouncements);
    _loadFilteredUsersAnnouncements();
  }

  @override
  void dispose() {
    _filterNotifier.removeListener(_loadFilteredUsersAnnouncements);
    super.dispose();
  }

  Future<void> _loadFilteredUsersAnnouncements() async {
    setState(() {
      _isLoading = true; // Show progress indicator
    });

    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final String? currentUserId =
        _authService.getCurrentUserId(); // Get the current user's UID

    try {
      List<Map<String, dynamic>> announcements = [];

      if (widget.isAllAnnouncSelected) {
        // Fetch all users' announcements
        List<Map<String, dynamic>> users =
            await _authService.fetchAllUsersWithinFilter(
          userProfileState.userProfile.filterLookingForDogOwner,
          userProfileState.userProfile.filterLookingForDogSitter,
          userProfileState.userProfile.filterDistance,
          userProfileState.userProfile.latitude,
          userProfileState.userProfile.longitude,
          userProfileState.userProfile.filterLastOnline,
        );

        // Exclude the current user's profile from the list
        users = users.where((user) => user['uid'] != currentUserId).toList();

        for (var user in users) {
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
      } else {
        // Fetch only the current user's announcements
        final userAnnouncements = await _fetchUserAnnouncements(currentUserId!);
        if (userAnnouncements.isNotEmpty) {
          announcements = userAnnouncements
              .map((announcement) async => {
                    'user': await _authService.fetchUserProfile(),
                    'announcement': announcement,
                  })
              .cast<Map<String, dynamic>>()
              .toList();
        }
      }

      // Sort announcements by the createdAt field
      announcements.sort((a, b) {
        final dateA = DateTime.parse(a['announcement']['createdAt']);
        final dateB = DateTime.parse(b['announcement']['createdAt']);
        return dateB.compareTo(dateA); // Newest first
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
      developer.log('Error fetching announcements: $e');
      return [];
    }
  }

  // Helper method to calculate distance between two coordinates
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

  // Helper method to format time ago
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

  // Build the announcement card widget
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

    // Get the main user's latitude and longitude from UserProfileState
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final mainUserLatitude = userProfileState.userProfile.latitude;
    final mainUserLongitude = userProfileState.userProfile.longitude;

    // Calculate the distance between the main user and the announcement user
    final distance = _calculateDistance(
      mainUserLatitude,
      mainUserLongitude,
      user['latitude'].toDouble(),
      user['longitude'].toDouble(),
    ).toStringAsFixed(1);

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
                      Text(
                        userName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.customBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcementTitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.customBlack,
                        ),
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
              '$timeAgo • $distance km',
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
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text:
                'No announcements found 😔\n\nAdjust your filter settings\nand spread the word about ',
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

    return RefreshIndicator(
      onRefresh: _loadFilteredUsersAnnouncements,
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
