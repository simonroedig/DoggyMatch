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

class SearchPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;

  const SearchPage({super.key, required this.profileCloseNotifier});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  bool _isFilterOpen = false;
  bool _isProfilesSelected = true; // To track toggle state
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
                Expanded(
                  child: Container(
                    color: AppColors.bg,
                    child: _isProfilesSelected
                        ? OtherPersons(
                            onProfileSelected: _openProfile,
                          )
                        : const Center(
                            child: Text(
                              "No announcements available.",
                              style: TextStyle(
                                color: AppColors.customBlack,
                                fontSize: 18,
                              ),
                            ),
                          ),
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
