// search_page.dart
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
import 'package:doggymatch_flutter/toggles/profiles_announcement_toggle.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/new_announcement_page.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons_announcements.dart';
import 'package:doggymatch_flutter/toggles/own_all_announcements_toggle.dart'; // Import the custom toggle

class SearchPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;

  const SearchPage({super.key, required this.profileCloseNotifier});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  bool _isFilterOpen = false;
  bool _isProfilesSelected = true; // To track toggle state
  bool _showOnlyCurrentUser =
      false; // Track the toggle state for including/excluding current user
  UserProfile? _selectedProfile;
  String? _selectedDistance;
  String? _lastOnline;
  bool? _isSaved;

  @override
  void initState() {
    super.initState();
    widget.profileCloseNotifier.addListener(_onProfileClose);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_authService.updateLastOnline(); // Call your function here
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
    Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  void _onToggle(bool isProfilesSelected) {
    setState(() {
      _isProfilesSelected = isProfilesSelected;

      // Reset to show all announcements when switching back to Shouts
      if (!_isProfilesSelected) {
        _showOnlyCurrentUser =
            false; // Reset to show all announcements by default
        // Ensure that announcements are reloaded with the correct filter
        _loadFilteredUsersAnnouncements();
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

  void _onOwnAllAnnouncementsToggle(bool isAllSelected) {
    setState(() {
      _showOnlyCurrentUser = isAllSelected;
      _loadFilteredUsersAnnouncements();
    });
    // Trigger the announcement reload to reflect the changes immediately
    Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  void _loadFilteredUsersAnnouncements() {
    // This function will trigger a re-fetch of the announcements when called
    Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
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
                ProfilesAnnouncementToggle(
                  onToggle: _onToggle,
                ),
                SizedBox(height: _isProfilesSelected ? 15 : 5),
                if (!_isProfilesSelected) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OwnAllAnnouncementsToggle(
                        onToggle: _onOwnAllAnnouncementsToggle,
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
                      key: ValueKey(
                          _showOnlyCurrentUser), // This forces a rebuild when toggling
                      showOnlyCurrentUser: _showOnlyCurrentUser,
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
                            distance: double.parse(_selectedDistance ?? '?'),
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
    );
  }
}
