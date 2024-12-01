// search_page.dart
// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:doggymatch_flutter/services/profile_service.dart';
import 'dart:developer' as developer;
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/filter_menu.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
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
  final Function(UserProfile, String, String, bool) onProfileSelected;

  const SearchPage({Key? key, required this.onProfileSelected})
      : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  bool _isFilterOpen = false;
  int _selectedToggleIndex = 0; // 0 - Profiles, 1 - Announcements, 2 - Posts

  bool _hasOpenedProfileFromUserId = false;

  // State variables for toggles
  PostFilterOption _selectedPostFilterOption = PostFilterOption.allPosts;
  ShoutsFilterOption _selectedShoutFilterOption = ShoutsFilterOption.allShouts;

  @override
  bool get wantKeepAlive => true; // Tell Flutter to keep this widget alive

  @override
  void initState() {
    super.initState();
    developer.log('Widget Initialized: $runtimeType');
    // Removed profileCloseNotifier listener
  }

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
    // Removed profileCloseNotifier listener
    developer.log('Widget Disposed: $runtimeType');
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  void _openProfile(
      UserProfile profile, String distance, String lastOnline, bool isSaved) {
    widget.onProfileSelected(profile, distance, lastOnline, isSaved);
  }

  void _applyFilterChanges() {
    setState(() {
      _isFilterOpen = false;
    });
  }

  void _onToggle(int selectedIndex) {
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
    setState(() {
      _selectedPostFilterOption = selectedOption;
      _loadFilteredUsersContent();
    });
  }

  // Update this function to accept ShoutsFilterOption instead of bool
  void _onAnnouncementsToggle(ShoutsFilterOption selectedOption) {
    setState(() {
      _selectedShoutFilterOption = selectedOption;
      _loadFilteredUsersContent();
    });
  }

  void _loadFilteredUsersContent() {
    // Implement filtering logic if needed
  }

  Future<bool> _onWillPop() async {
    if (_isFilterOpen) {
      setState(() {
        _isFilterOpen = false;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important when using AutomaticKeepAliveClientMixin
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
                  ),
                  SizedBox(height: _selectedToggleIndex == 0 ? 15 : 5),
                  if (_selectedToggleIndex == 1) ...[
                    // Announcements State
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnnouncementsToggle(
                          onToggle: _onAnnouncementsToggle,
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
                  ] else if (_selectedToggleIndex == 2) ...[
                    // Posts State
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PostsToggle(
                          onToggle: _onPostsToggle,
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
                  ] else
                    Expanded(
                      child: OtherPersons(
                        onProfileSelected: _openProfile,
                        showAllProfiles: true,
                        showSavedProfiles: false,
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
              // Removed the profile overlay code
            ],
          ),
        ),
      ),
    );
  }
}
