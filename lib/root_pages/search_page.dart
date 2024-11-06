// search_page.dart
// ignore_for_file: use_super_parameters, deprecated_member_use

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

class SearchPageState extends State<SearchPage> {
  bool _isFilterOpen = false;
  int _selectedToggleIndex = 0; // 0 - Profiles, 1 - Announcements, 2 - Posts
  UserProfile? _selectedProfile;
  String? _selectedDistance;
  String? _lastOnline;
  bool? _isSaved;

  // State variables for toggles
  PostFilterOption _selectedPostFilterOption = PostFilterOption.allPosts;
  ShoutsFilterOption _selectedShoutFilterOption = ShoutsFilterOption.allShouts;

  @override
  void initState() {
    super.initState();
    widget.profileCloseNotifier.addListener(_onProfileClose);
  }

  @override
  void dispose() {
    widget.profileCloseNotifier.removeListener(_onProfileClose);
    super.dispose();
  }

  void _onProfileClose() {
    if (widget.profileCloseNotifier.shouldCloseProfile) {
      closeProfile();
      widget.profileCloseNotifier.reset();
    }
  }

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  void closeProfile() {
    setState(() {
      _selectedProfile = null;
    });
    Provider.of<UserProfileState>(context, listen: false).closeProfile();
  }

  void _openProfile(
      UserProfile profile, String distance, String lastOnline, bool isSaved) {
    setState(() {
      _selectedProfile = profile;
      _selectedDistance = distance;
      _lastOnline = lastOnline;
      _isSaved = isSaved;
    });
    Provider.of<UserProfileState>(context, listen: false).openProfile();
  }

  void _applyFilterChanges() {
    setState(() {
      _isFilterOpen = false;
    });
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
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
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  // Update this function to accept ShoutsFilterOption instead of bool
  void _onAnnouncementsToggle(ShoutsFilterOption selectedOption) {
    setState(() {
      _selectedShoutFilterOption = selectedOption;
      _loadFilteredUsersContent();
    });
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  void _loadFilteredUsersContent() {
    //Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
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
                          iconSize: 48,
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
                          iconSize: 48,
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
                            borderRadius: BorderRadius.circular(16.0),
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
