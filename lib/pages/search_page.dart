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

class SearchPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;

  const SearchPage({super.key, required this.profileCloseNotifier});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  bool _isFilterOpen = false;
  UserProfile? _selectedProfile;

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

  void _openProfile(UserProfile profile) {
    setState(() {
      _selectedProfile = profile;
    });
    Provider.of<UserProfileState>(context, listen: false).openProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Consumer<UserProfileState>(
        builder: (context, userProfileState, child) {
          return Column(
            children: [
              CustomAppBar(
                isFilterOpen: _isFilterOpen,
                toggleFilter: _toggleFilter,
                showFilterIcon: true,
                onSettingsPressed: null,
                isProfileOpen: userProfileState
                    .isProfileOpen, // Pass isProfileOpen state here
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      color: AppColors.bg,
                      child: OtherPersons(
                        onProfileSelected: _openProfile,
                      ),
                    ),
                    if (_isFilterOpen) const FilterMenu(),
                    if (_selectedProfile != null)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: closeProfile,
                          child: Container(
                            color: Colors.black.withOpacity(0),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Material(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Colors.transparent,
                                  child: ProfileWidget(
                                    profile: _selectedProfile!,
                                    clickedOnOtherUser: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
