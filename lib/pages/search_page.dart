import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/widgets/filter_menu.dart';
import 'package:doggymatch_flutter/widgets/search/other_persons.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_widget.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/pages/notifiers/profile_close_notifier.dart';
import 'package:doggymatch_flutter/pages/notifiers/filter_notifier.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/widgets/search/profiles_announcement_toggle.dart';
import 'package:doggymatch_flutter/pages/new_announcement_page.dart';
import 'package:doggymatch_flutter/widgets/search/other_persons_announcements.dart';
import 'package:doggymatch_flutter/pages/announcements/own_all_announcements_toggle.dart';

class SearchPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;

  const SearchPage({super.key, required this.profileCloseNotifier});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  bool _isFilterOpen = false;
  bool _isProfilesSelected = true; // To track toggle state
  bool _isAllAnnouncSelected = true; // Track Own/All Shouts toggle state
  UserProfile? _selectedProfile;
  String? _selectedDistance;
  String? _lastOnline;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    widget.profileCloseNotifier.addListener(_onProfileClose);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService.updateLastOnline(); // Call your function here
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

  void _openProfile(UserProfile profile, String distance, String lastOnline) {
    setState(() {
      _selectedProfile = profile;
      _selectedDistance = distance;
      _lastOnline = lastOnline;
    });
    Provider.of<UserProfileState>(context, listen: false).openProfile();
  }

  void _applyFilterChanges() {
    setState(() {
      _isFilterOpen = false;
    });
    // Optionally, refresh the profiles list or trigger a rebuild
    Provider.of<UserProfileState>(context, listen: false).refreshUserProfile();
  }

  void _onToggle(bool isProfilesSelected) {
    setState(() {
      _isProfilesSelected = isProfilesSelected;
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
      _isAllAnnouncSelected = isAllSelected;
    });
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
                  // Row for both buttons: toggle on the left, add icon on the right
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the whole group
                    children: [
                      // Centered OwnAllAnnouncementsToggle
                      OwnAllAnnouncementsToggle(
                        onToggle: _onOwnAllAnnouncementsToggle,
                      ),
                      // Add some spacing between the toggle and the icon
                      const SizedBox(
                          width:
                              16), // Adjust this width for spacing between the two elements
                      // Centered Add Circle Icon
                      IconButton(
                        iconSize: 48, // Size of the icon
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.customBlack,
                        ),
                        onPressed: _navigateToNewAnnouncement,
                      ),
                    ],
                  ),

                  const SizedBox(height: 0), // Spacing below the buttons
                  // Display OtherPersonsAnnouncements list
                  Expanded(
                    child: OtherPersonsAnnouncements(
                      isAllAnnouncSelected:
                          _isAllAnnouncSelected, // Pass the toggle state
                    ),
                  ),
                ] else
                  // Display OtherPersons when profiles are selected
                  Expanded(
                    child: OtherPersons(
                      onProfileSelected: _openProfile,
                    ),
                  ),
              ],
            ),
            if (_isFilterOpen)
              Positioned(
                top:
                    kToolbarHeight - 55, // Positioning it just below the AppBar
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
