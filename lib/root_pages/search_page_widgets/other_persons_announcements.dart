// other_persons_announcements.dart

// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/friend_and_save_icon.dart';
import 'package:doggymatch_flutter/services/friends_service.dart';
import 'package:doggymatch_flutter/services/report_service.dart';
import 'package:doggymatch_flutter/shared_helper/icon_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/services/auth_service.dart';
import 'package:doggymatch_flutter/notifiers/filter_notifier.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/ENUM_shouts_filter_option.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/shared_helper/autoscrolling.dart';

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

class _OtherPersonsAnnouncementsState extends State<OtherPersonsAnnouncements>
    with AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  final _authProfile = ProfileService();

  bool _isLoading = true;

  final iconHelpers = IconHelpers();

  List<Map<String, dynamic>> _announcements = [];

  late FilterNotifier _filterNotifier;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _filterNotifier = Provider.of<FilterNotifier>(context, listen: false);

    _filterNotifier.addListener(_loadFilteredUsersAnnouncements);

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
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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
          users = await _authProfile.fetchAllUsersWithinFilter(
            userProfileState.userProfile.filterLookingForDogOwner,
            userProfileState.userProfile.filterLookingForDogSitter,
            userProfileState.userProfile.filterDistance,
            userProfileState.userProfile.latitude,
            userProfileState.userProfile.longitude,
            userProfileState.userProfile.filterLastOnline,
          );

          for (int i = users.length - 1; i >= 0; i--) {
            final bool isUserBlocked =
                await ReportService().isBlocked(users[i]['uid']);
            if (isUserBlocked) {
              users.removeAt(i);
            }
          }

          for (var user in users) {
            final userAnnouncements =
                await _fetchUserAnnouncements(user['uid']);
            for (var announcement in userAnnouncements) {
              announcements.add({
                'user': user['firestoreData'],
                'announcement': announcement,
              });
              /*
              if (currentUserId != user['uid']) {
                announcements.add({
                  'user': user['firestoreData'],
                  'announcement': announcement,
                });
              }
              */
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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

        // if the friend is blocked, skip to the next friend
        final isFriendBlocked = await ReportService().isBlocked(friendId);
        if (isFriendBlocked) {
          continue;
        }

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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important to call super.build

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
        padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          return AnnouncementCard(
            announcementData: _announcements[index],
            onProfileSelected: widget.onProfileSelected,
          );
        },
      ),
    );
  }
}

// New AnnouncementCard Widget
class AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> announcementData;
  final Function(UserProfile, String, String, bool) onProfileSelected;

  const AnnouncementCard({
    Key? key,
    required this.announcementData,
    required this.onProfileSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = announcementData['user'];
    final announcement = announcementData['announcement'];
    final DateTime createdAt = DateTime.parse(announcement['createdAt']);
    final String timeAgo = calculateTimeAgo(createdAt);

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

    final distance = calculateDistance(
      mainUserLatitude,
      mainUserLongitude,
      user['latitude'].toDouble(),
      user['longitude'].toDouble(),
    ).toStringAsFixed(1);

    final String currentUserId = AuthService().getCurrentUserId() ?? '';

    return GestureDetector(
      onTap: () {
        if (user['uid'] != currentUserId) {
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
            filterDistance: user['filterDistance'] != null
                ? (user['filterDistance'] as num).toDouble()
                : 10.0,
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

          // Fetch the actual saved status
          final profileService = ProfileService();
          profileService.isProfileSaved(user['uid']).then((isSaved) {
            onProfileSelected(selectedProfile, distance, lastOnline, isSaved);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.only(
            left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
          color: profileColor,
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
          border: Border.all(color: AppColors.customBlack, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        // Profile Image
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(UIConstants.innerRadius),
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
                                profileImage,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Friend Icon
                        Positioned(
                          bottom: -4,
                          left: -4,
                          child: FriendIconWidget(
                            userId: user['uid'],
                            profileColor: profileColor,
                          ),
                        ),
                        // Save Icon
                        Positioned(
                          top: -4,
                          right: -4,
                          child: SaveIconWidget(
                            userId: user['uid'],
                            profileColor: profileColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                        height: 74,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0.0),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius:
                              BorderRadius.circular(UIConstants.innerRadius),
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
                            AutoScrollingTitleRow(
                              title: announcementTitle,
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
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(UIConstants.innerRadius),
                  border: Border.all(color: AppColors.customBlack, width: 3),
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
                user['uid'] == currentUserId
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
      ),
    );
  }
}
