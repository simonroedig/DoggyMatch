// profile_widget.dart

// ignore_for_file: use_super_parameters

import 'package:doggymatch_flutter/services/auth_service.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_edit_all.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_image_stack.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_info_sections.dart';
import 'package:doggymatch_flutter/root_pages/chat_page_widgets/profile_chat.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/services/friends_service.dart';
import 'package:doggymatch_flutter/root_pages/community_page_widgets/friends_dialogs.dart';
import 'package:doggymatch_flutter/services/announcement_service.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_posts_section.dart'; // Import the new page
import 'package:doggymatch_flutter/services/profile_service.dart';

class ProfileWidget extends StatefulWidget {
  final UserProfile profile;
  final bool clickedOnOtherUser;
  final double distance;
  final String lastOnline;
  final bool startInChat;
  final bool isProfileSaved;

  const ProfileWidget({
    Key? key,
    required this.profile,
    required this.clickedOnOtherUser,
    required this.distance,
    required this.lastOnline,
    required this.isProfileSaved,
    this.startInChat = false,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final _authProfile = ProfileService();
  bool _isInChat = false;
  bool _isProfileSaved = false; // Track if profile is saved
  bool _isProfileFriendRequestSent =
      false; // Track if friend request is sent to other person
  bool _isProfileFriendRequestReceived =
      false; // Track if friend request is received from other person
  bool _isProfileFriend = false; // Track if profile is a friend
  Map<String, dynamic>? _announcementData; // Holds the announcement data

  List<Map<String, dynamic>> _userPosts = []; // Holds the user's posts
  List<Map<String, dynamic>> _savedPosts = [];

  @override
  void initState() {
    super.initState();
    _isInChat = widget.startInChat;
    _isProfileSaved = widget.isProfileSaved;
    // Log the UID of the profile
    log('Profile uid: ${widget.profile.uid}');
    // Log the UID of the own user
    log('Own uid: ${AuthService().getCurrentUserId()}');

    _checkIfISentFriendRequest();
    _checkIfIReceivedFriendRequest();
    _checkIfProfileFriend();
    _fetchAnnouncementData(); // Fetch the announcement data
    _fetchUserPosts(); // Fetch the user's posts
    if (!widget.clickedOnOtherUser) {
      //_fetchSavedPosts();
    }
  }

  // Method to fetch the user's posts
  void _fetchUserPosts() async {
    try {
      final posts = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.profile.uid)
          .collection('user_posts')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _userPosts = posts.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      log('Error fetching user posts: $e');
    }
  }

  // Method to fetch the announcement data
  void _fetchAnnouncementData() async {
    Map<String, dynamic>? data =
        await AnnouncementService().getAnnouncementForUser(widget.profile.uid);
    setState(() {
      _announcementData = data;
    });
  }

  Future<void> _checkIfISentFriendRequest() async {
    bool isFriendRequestSent =
        await FriendsService().isFriendRequestSent(widget.profile.uid);
    setState(() {
      _isProfileFriendRequestSent = isFriendRequestSent;
    });
  }

  Future<void> _checkIfIReceivedFriendRequest() async {
    bool isFriendRequestReceived =
        await FriendsService().isFriendRequestReceived(widget.profile.uid);
    setState(() {
      _isProfileFriendRequestReceived = isFriendRequestReceived;
    });
  }

  Future<void> _checkIfProfileFriend() async {
    bool isFriend = await FriendsService().areFriends(widget.profile.uid);
    setState(() {
      _isProfileFriend = isFriend;
    });
  }

  Future<void> toggleFriendStatus() async {
    if (!_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      bool? confirmed = await FriendsDialogs.showSendFriendRequestDialog(
          context, widget.profile.userName);
      if (confirmed == true) {
        await FriendsService().sendFriendRequest(widget.profile.uid);
        setState(() {
          _isProfileFriendRequestSent = true;
        });
      }
    } else if (!_isProfileFriend &&
        _isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      bool? confirmed = await FriendsDialogs.showCancelFriendRequestDialog(
          context, widget.profile.userName);
      if (confirmed == true) {
        await FriendsService().cancelFriendRequest(widget.profile.uid);
        setState(() {
          _isProfileFriendRequestSent = false;
        });
      }
    } else if (_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      bool? confirmed = await FriendsDialogs.showUnfriendDialog(
          context, widget.profile.userName);
      if (confirmed == true) {
        await FriendsService().removeFriend(widget.profile.uid);
        setState(() {
          _isProfileFriend = false;
        });
      }
    } else if (!_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        _isProfileFriendRequestReceived) {
      bool? confirmed = await FriendsDialogs.showAcceptFriendRequestDialog(
          context, widget.profile.userName);
      if (confirmed == true) {
        await FriendsService().makeFriends(widget.profile.uid);
        setState(() {
          _isProfileFriend = true;
          _isProfileFriendRequestReceived = false;
        });
      } else if (confirmed == false) {
        await FriendsService().removeReceivedFriendRequest(widget.profile.uid);
        setState(() {
          _isProfileFriendRequestReceived = false;
        });
      }
    }
  }

  Icon? getIcon1BasedOnState() {
    Color color = AppColors.customBlack;

    if (!_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      return Icon(
        Icons.people_alt_outlined,
        color: color,
      );
    } else if (!_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        _isProfileFriendRequestReceived) {
      return Icon(
        Icons.people_alt_rounded,
        color: color,
      );
    } else if (!_isProfileFriend &&
        _isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      return Icon(
        Icons.people_alt_rounded,
        color: color,
      );
    } else if (_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      return Icon(
        Icons.people_alt_rounded,
        color: color,
      );
    } else {
      return null;
    }
  }

  Icon? getIcon2BasedOnState() {
    double size = 16.0;
    Color color = AppColors.customBlack;

    if (!_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      return Icon(
        Icons.add_rounded,
        color: color,
        size: size,
      );
    } else if (!_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        _isProfileFriendRequestReceived) {
      return Icon(
        Icons.call_received_rounded,
        color: color,
        size: size,
      );
    } else if (!_isProfileFriend &&
        _isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      return Icon(
        Icons.call_made_rounded,
        color: color,
        size: size,
      );
    } else if (_isProfileFriend &&
        !_isProfileFriendRequestSent &&
        !_isProfileFriendRequestReceived) {
      return Icon(
        Icons.check_rounded,
        color: color,
        size: size,
      );
    } else {
      return null;
    }
  }

  Future<void> _toggleSavedStatus() async {
    if (_isProfileSaved) {
      // Unsave the profile
      await _authProfile.unsaveUserProfile(widget.profile.uid);
    } else {
      // Save the profile
      await _authProfile.saveUserProfile(widget.profile.uid);
    }
    setState(() {
      _isProfileSaved = !_isProfileSaved;
    });
  }

  void _openUserPostsPage(int initialIndex, {required bool isSavedPosts}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserPostsPage(
          user: widget.profile.toMap(),
          posts: isSavedPosts ? _savedPosts : _userPosts,
          initialIndex: initialIndex,
          isSavedPosts: isSavedPosts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg, // Set the background color here
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal:
                17.0), // Adjust padding to create space on the left and right
        child: _buildProfileContainer(
          child: Column(
            children: [
              if (!_isInChat)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ProfileImageStack(
                            profile: widget.profile,
                            clickedOnOtherUser: widget.clickedOnOtherUser),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              UserInfoSection(
                                  profile: widget.profile,
                                  clickedOnOtherUser: widget.clickedOnOtherUser,
                                  distance: widget.distance,
                                  lastOnline: widget.lastOnline),
                              if (widget.profile.isDogOwner)
                                DogInfoSection(profile: widget.profile),
                              AboutSection(profile: widget.profile),
                              if (_announcementData != null)
                                ShoutSection(
                                  announcementTitle:
                                      _announcementData!['announcementTitle'] ??
                                          '',
                                  announcementText:
                                      _announcementData!['announcementText'] ??
                                          '',
                                  createdAt: DateTime.parse(
                                      _announcementData!['createdAt']),
                                  isOwnProfile: !widget.clickedOnOtherUser,
                                ),
                              if (_userPosts.isNotEmpty)
                                PostsSection(
                                  userPosts: _userPosts,
                                  onPostSelected: (index) {
                                    _openUserPostsPage(index,
                                        isSavedPosts: false);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ProfileChat(
                    otherUserProfile: widget.profile,
                    onHeaderTapped: () {
                      setState(() {
                        _isInChat = false; // Go back to profile view
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color:
            _isInChat ? AppColors.brownLightest : widget.profile.profileColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppColors.customBlack,
          width: 3.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21.0),
        child: child,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              widget.profile.isDogOwner
                  ? Icons.pets_rounded
                  : Icons.person_rounded,
              color: AppColors.customBlack,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.profile.isDogOwner ? 'Dog Owner' : 'Dog Sitter',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.customBlack,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (widget.clickedOnOtherUser) ...[
              Transform.translate(
                offset:
                    const Offset(7, 0), // Move the first button to the right
                child: IconButton(
                  padding: EdgeInsets.zero, // Remove default padding
                  onPressed: () {
                    // Handle add friend action here
                    toggleFriendStatus();
                  },
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(child: getIcon1BasedOnState()),
                      const SizedBox(width: 4),
                      Transform.translate(
                        offset: const Offset(
                            -6, -3), // Adjust icon position as needed
                        child: getIcon2BasedOnState(),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(
                    0, 0), // Move the bookmark icon (adjust 5 as needed)
                child: IconButton(
                  icon: Icon(
                    _isProfileSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: AppColors.customBlack,
                  ),
                  onPressed: _toggleSavedStatus, // Toggle saved status on press
                ),
              ),
            ],
            IconButton(
              icon: Icon(
                _isInChat
                    ? Icons.arrow_back_rounded
                    : widget.clickedOnOtherUser
                        ? Icons.message_rounded
                        : Icons.border_color_rounded,
                color: AppColors.customBlack,
              ),
              onPressed: () {
                setState(() {
                  if (_isInChat) {
                    _isInChat = false; // Go back to profile view
                  } else {
                    if (widget.clickedOnOtherUser) {
                      _isInChat = true; // Switch to chat view
                    } else {
                      _openEditProfileDialog(context); // Open edit profile
                    }
                  }
                });
              },
            ),
          ],
        )
      ],
    );
  }

  void _openEditProfileDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileImageEdit(
          profile: widget.profile,
        ),
      ),
    );
  }
}
