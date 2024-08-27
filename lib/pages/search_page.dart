import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/widgets/filter_menu.dart';
import 'package:doggymatch_flutter/widgets/search/other_persons.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_widget.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  bool _isFilterOpen = false;
  UserProfile? _selectedProfile;

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  void _openProfile(UserProfile profile) {
    setState(() {
      _selectedProfile = profile;
    });
    Provider.of<UserProfileState>(context, listen: false)
        .toggleProfileOpen(true);
  }

  void _closeProfile() {
    setState(() {
      _selectedProfile = null;
    });
    Provider.of<UserProfileState>(context, listen: false)
        .toggleProfileOpen(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          CustomAppBar(
            isFilterOpen: _isFilterOpen,
            toggleFilter: _toggleFilter,
            showFilterIcon: true,
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: AppColors.bg,
                  child: OtherPersons(
                    onProfileSelected:
                        _openProfile, // Pass function to OtherPersons
                  ),
                ),
                if (_isFilterOpen) const FilterMenu(),
                if (_selectedProfile != null)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _closeProfile,
                      child: Container(
                        color: Colors.black.withOpacity(0), // Darken background
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
      ),
    );
  }
}
