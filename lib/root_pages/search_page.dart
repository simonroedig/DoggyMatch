// search_page.dart
// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'dart:developer' as developer;
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/filter_menu.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_widget.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/notifiers/profile_close_notifier.dart';
import 'package:doggymatch_flutter/notifiers/filter_notifier.dart';
import 'package:doggymatch_flutter/toggles/profile_announcement_posts_toggle.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/new_announcement_page.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/new_post_page.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons_announcements.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons_posts.dart';
import 'package:doggymatch_flutter/toggles/announcements_toggle.dart';
import 'package:doggymatch_flutter/toggles/posts_toggle.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/ENUM_post_filter_option.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/ENUM_shouts_filter_option.dart';

class SearchPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;

  const SearchPage({Key? key, required this.profileCloseNotifier})
      : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  bool _isFilterOpen = false;
  int _selectedToggleIndex = 0; // 0 - Profiles, 1 - Announcements, 2 - Posts
  UserProfile? _selectedProfile;
  String? _selectedDistance;
  String? _lastOnline;
  bool? _isSaved;

  bool _hasOpenedProfileFromUserId = false;

  // State variables for toggles
  PostFilterOption _selectedPostFilterOption = PostFilterOption.allPosts;
  ShoutsFilterOption _selectedShoutFilterOption = ShoutsFilterOption.allShouts;

  @override
  bool get wantKeepAlive => true; // Tell Flutter to keep this widget alive

  // Track the starting position for swipe detection
  late double _startDragX;
  late double _startDragY;

  @override
  void initState() {
    super.initState();
    developer.log('Widget Initialized: $runtimeType');
    widget.profileCloseNotifier.addListener(_onProfileClose);

    // NEW: Listen for userIdToOpen changes in UserProfileState.
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    userProfileState.addListener(_onUserProfileStateChanged);
  }

  void _onUserProfileStateChanged() async {
    if (!mounted) return;
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);

    if (userProfileState.userIdToOpen != null) {
      final userId = userProfileState.userIdToOpen!;

      try {
        final profileData =
            await ProfileService().fetchOtherUserProfile(userId);
        if (profileData != null) {
          final distance = calculateDistance(
            userProfileState.userProfile.latitude,
            userProfileState.userProfile.longitude,
            profileData.latitude,
            profileData.longitude,
          ).toStringAsFixed(1);

          final lastOnline = calculateLastOnlineLong(profileData.lastOnline);
          final isSaved = await ProfileService().isProfileSaved(userId);

          // Actually open the profile
          _openProfile(profileData, distance, lastOnline, isSaved);
        }
      } catch (e) {
        // handle error if needed
      }

      // Reset so we don't keep reopening
      userProfileState.resetUserIdToOpen();
    }
  }

  /*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasOpenedProfileFromUserId) {
      final userProfileState =
          Provider.of<UserProfileState>(context, listen: false);
      final userId = userProfileState.userIdToOpen;
      if (userId != null) {
        developer.log('Opening profile from user id: $userId');
        _openProfileById(userId);
        _hasOpenedProfileFromUserId = true;
        userProfileState.resetUserIdToOpen();
      }
    }
  }
  */

  void _openProfileById(String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final profileData =
            await ProfileService().fetchOtherUserProfile(userId);
        if (profileData != null && mounted) {
          final userProfile = profileData;
          final userProfileState =
              Provider.of<UserProfileState>(context, listen: false);
          final distance = calculateDistance(
            userProfileState.userProfile.latitude,
            userProfileState.userProfile.longitude,
            userProfile.latitude,
            userProfile.longitude,
          ).toStringAsFixed(1);
          final lastOnline = calculateLastOnlineLong(userProfile.lastOnline);
          final isSaved = await ProfileService().isProfileSaved(userId);

          // Open profile automatically
          _openProfile(userProfile, distance, lastOnline, isSaved);
        }
      } catch (e) {
        if (mounted) {
          developer.log('Error loading profile: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    widget.profileCloseNotifier.removeListener(_onProfileClose);
    developer.log('Widget Disposed: $runtimeType');
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    userProfileState.removeListener(_onUserProfileStateChanged);
    super.dispose();
  }

  void _onProfileClose() {
    if (widget.profileCloseNotifier.shouldCloseProfile) {
      closeProfile();
      widget.profileCloseNotifier.reset();
    }
  }

  void _toggleFilter() {
    if (!mounted) return;
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  void closeProfile() {
    if (!mounted) return;
    setState(() {
      _selectedProfile = null;
    });
    Provider.of<UserProfileState>(context, listen: false).closeProfile();
  }

  void _openProfile(
      UserProfile profile, String distance, String lastOnline, bool isSaved) {
    if (!mounted) return;
    setState(() {
      _selectedProfile = profile;
      _selectedDistance = distance;
      _lastOnline = lastOnline;
      _isSaved = isSaved;
    });
    Provider.of<UserProfileState>(context, listen: false).openProfile();
  }

  void _applyFilterChanges() {
    if (!mounted) return;
    setState(() {
      _isFilterOpen = false;
    });
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _startDragX = details.globalPosition.dx;
    _startDragY = details.globalPosition.dy;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    const double minDragDistance = 50.0; // Minimum distance to trigger swipe
    final double dragDistance = _startDragX - details.globalPosition.dx;

    if (dragDistance.abs() < minDragDistance) {
      return; // Not a swipe, just a tap
    }

    if (!mounted) return;

    // Check if we're in Shouts or Posts state to determine split swipe logic
    if (_selectedToggleIndex == 1 || _selectedToggleIndex == 2) {
      // Get the middle of the screen to determine top/bottom half
      final screenHeight = MediaQuery.of(context).size.height;
      final isTopHalf = _startDragY < screenHeight / 2;

      if (isTopHalf) {
        // Top half: swipe between Profiles, Shouts, Posts (main toggle)
        if (dragDistance < -minDragDistance) {
          setState(() {
            _selectedToggleIndex = (_selectedToggleIndex - 1) % 3;
          });
        } else if (dragDistance > minDragDistance) {
          setState(() {
            _selectedToggleIndex = (_selectedToggleIndex + 1) % 3;
          });
        }
      } else {
        // Bottom half: swipe within secondary toggle (announcements or posts filter)
        if (_selectedToggleIndex == 1) {
          // Shouts: cycle through ShoutsFilterOption
          if (dragDistance < -minDragDistance) {
            // Swipe left (right to left) -> next option
            final options = ShoutsFilterOption.values;
            final currentIndex = options.indexOf(_selectedShoutFilterOption);
            _onAnnouncementsToggle(
                options[(currentIndex + 1) % options.length]);
          } else if (dragDistance > minDragDistance) {
            // Swipe right (left to right) -> previous option
            final options = ShoutsFilterOption.values;
            final currentIndex = options.indexOf(_selectedShoutFilterOption);
            _onAnnouncementsToggle(
                options[(currentIndex - 1 + options.length) % options.length]);
          }
        } else if (_selectedToggleIndex == 2) {
          // Posts: cycle through PostFilterOption
          if (dragDistance < -minDragDistance) {
            // Swipe left (right to left) -> next option
            final options = PostFilterOption.values;
            final currentIndex = options.indexOf(_selectedPostFilterOption);
            _onPostsToggle(options[(currentIndex + 1) % options.length]);
          } else if (dragDistance > minDragDistance) {
            // Swipe right (left to right) -> previous option
            final options = PostFilterOption.values;
            final currentIndex = options.indexOf(_selectedPostFilterOption);
            _onPostsToggle(
                options[(currentIndex - 1 + options.length) % options.length]);
          }
        }
      }
    } else {
      // Profiles: simple swipe between tabs (no secondary toggle)
      if (dragDistance < -minDragDistance) {
        setState(() {
          _selectedToggleIndex = (_selectedToggleIndex - 1) % 3;
        });
      } else if (dragDistance > minDragDistance) {
        setState(() {
          _selectedToggleIndex = (_selectedToggleIndex + 1) % 3;
        });
      }
    }
  }

  void _onToggle(int selectedIndex) {
    if (!mounted) return;
    setState(() {
      _selectedToggleIndex = selectedIndex;
    });
    /*
    setState(() {
      _selectedToggleIndex = selectedIndex;

      // Reset toggles when switching between tabs
      if (_selectedToggleIndex == 1) {
        _selectedShoutFilterOption = ShoutsFilterOption.allShouts;
        _loadFilteredUsersContent();
      } else if (_selectedToggleIndex == 2) {
        _selectedPostFilterOption = PostFilterOption.allPosts;
        _loadFilteredUsersContent();
      }
    });
    */
  }

  void _navigateToNewAnnouncement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewAnnouncementPage(),
      ),
    );
  }

  void _navigateToNewPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewPostPage(),
      ),
    );
  }

  // Update this function to accept PostFilterOption
  void _onPostsToggle(PostFilterOption selectedOption) {
    if (_selectedPostFilterOption != selectedOption) {
      if (!mounted) return;

      setState(() {
        _selectedPostFilterOption = selectedOption;
      });
    }
    /*
    setState(() {
      _selectedPostFilterOption = selectedOption;
      _loadFilteredUsersContent();
    });
    */
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  // Update this function to accept ShoutsFilterOption instead of bool
  void _onAnnouncementsToggle(ShoutsFilterOption selectedOption) {
    if (_selectedShoutFilterOption != selectedOption) {
      if (!mounted) return;

      setState(() {
        _selectedShoutFilterOption = selectedOption;
      });
      // Trigger data reload if needed
    }
    /*
    setState(() {
      _selectedShoutFilterOption = selectedOption;
      _loadFilteredUsersContent();
    });
    */
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  void _loadFilteredUsersContent() {
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  Future<bool> _onWillPop() async {
    if (_isFilterOpen) {
      if (!mounted) return false;

      setState(() {
        _isFilterOpen = false;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Important: call super.build when using AutomaticKeepAliveClientMixin
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ChangeNotifierProvider(
        create: (context) => FilterNotifier(),
        child: Scaffold(
          backgroundColor: AppColors.bg,
          appBar: CustomAppBar(
            isFilterOpen: _isFilterOpen,
            toggleFilter: _toggleFilter,
            showFilterIcon: true,
            onSettingsPressed: null,
            isProfileOpen: Provider.of<UserProfileState>(context).isProfileOpen,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 5),
                  ProfileAnnouncementPostsToggle(
                    onToggle: _onToggle,
                    currentIndex: _selectedToggleIndex,
                  ),
                  SizedBox(height: _selectedToggleIndex == 0 ? 15 : 5),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragStart: _handleHorizontalDragStart,
                      onHorizontalDragEnd: _handleHorizontalDragEnd,
                      child: IndexedStack(
                        index: _selectedToggleIndex,
                        children: [
                          // Index 0 - Profiles
                          OtherPersons(
                            onProfileSelected: _openProfile,
                            showAllProfiles: true,
                            showSavedProfiles: false,
                          ),
                          // Index 1 - Shouts (Announcements)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnnouncementsToggle(
                                    onToggle: _onAnnouncementsToggle,
                                    currentOption: _selectedShoutFilterOption,
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    iconSize: 47,
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: AppColors.customBlack,
                                    ),
                                    onPressed: _navigateToNewAnnouncement,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 0),
                              Expanded(
                                child: OtherPersonsAnnouncements(
                                  key: ValueKey(_selectedShoutFilterOption),
                                  selectedOption: _selectedShoutFilterOption,
                                  onProfileSelected: _openProfile,
                                ),
                              ),
                            ],
                          ),
                          // Index 2 - Posts
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PostsToggle(
                                    onToggle: _onPostsToggle,
                                    currentOption: _selectedPostFilterOption,
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    iconSize: 47,
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: AppColors.customBlack,
                                    ),
                                    onPressed: _navigateToNewPost,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 0),
                              Expanded(
                                child: OtherPersonsPosts(
                                  selectedOption: _selectedPostFilterOption,
                                  onProfileSelected: _openProfile,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_isFilterOpen)
                Positioned(
                  top: kToolbarHeight - 55,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FilterMenu(
                    onClose: _applyFilterChanges,
                  ),
                ),
              if (_selectedProfile != null)
                Positioned.fill(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          color: Colors.black.withOpacity(0),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Material(
                            borderRadius:
                                BorderRadius.circular(UIConstants.popUpRadius),
                            color: Colors.transparent,
                            child: ProfileWidget(
                              profile: _selectedProfile!,
                              clickedOnOtherUser: true,
                              distance: double.parse(_selectedDistance ?? '0'),
                              lastOnline: _lastOnline ?? '',
                              isProfileSaved: _isSaved ?? false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
