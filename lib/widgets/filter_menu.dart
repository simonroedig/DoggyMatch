import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/colors.dart';

class FilterMenu extends StatefulWidget {
  const FilterMenu({super.key});

  @override
  FilterMenuState createState() => FilterMenuState();
}

class FilterMenuState extends State<FilterMenu> {
  late double _currentDistanceValue;
  late bool _isDogOwnerSelected;
  late bool _isDogSitterSelected;

  @override
  void initState() {
    super.initState();
    // Initialize filter values based on the UserProfileState
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    _currentDistanceValue = userProfileState.userProfile.filterDistance;
    _isDogOwnerSelected = userProfileState.userProfile.filterLookingForDogOwner;
    _isDogSitterSelected =
        userProfileState.userProfile.filterLookingForDogSitter;
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = Provider.of<UserProfileState>(context);

    return Positioned(
      top: 0.0,
      left: MediaQuery.of(context).size.width * 0.05,
      right: MediaQuery.of(context).size.width * 0.05,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: AppColors.greyLightest,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: AppColors.customBlack,
            width: 3.0,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Search Filter",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.customBlack,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Looking For",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.customBlack,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10.0),
            _buildSelectionMenu(
              icon: Icons.pets_rounded,
              text: "Dog Owner",
              isSelected: _isDogOwnerSelected,
              onTap: () {
                setState(() {
                  _isDogOwnerSelected = !_isDogOwnerSelected;
                  _ensureAtLeastOneSelected();
                  _updateFilterSettings(userProfileState);
                });
              },
            ),
            const SizedBox(height: 10.0),
            _buildSelectionMenu(
              icon: Icons.person_rounded,
              text: "Dog Sitter",
              isSelected: _isDogSitterSelected,
              onTap: () {
                setState(() {
                  _isDogSitterSelected = !_isDogSitterSelected;
                  _ensureAtLeastOneSelected();
                  _updateFilterSettings(userProfileState);
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              _currentDistanceValue >= 30
                  ? "Distance >30 km"
                  : _currentDistanceValue <= 0.1
                      ? "Distance <0.1 km"
                      : "Distance ${_currentDistanceValue.toStringAsFixed(1)} km",
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.customBlack,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: Slider(
                    thumbColor: AppColors.brownDarkest,
                    activeColor: AppColors.brownDarkest,
                    inactiveColor: AppColors.brownLight,
                    value: _currentDistanceValue,
                    min: 0.1,
                    max: 30.0,
                    divisions: 300,
                    onChanged: (double value) {
                      setState(() {
                        _currentDistanceValue = value;
                        _updateFilterSettings(userProfileState);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionMenu({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.greyLightest,
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(
            color: isSelected ? AppColors.customBlack : AppColors.grey,
            width: 3.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.customBlack : AppColors.grey,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? AppColors.customBlack : AppColors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.customBlack,
              ),
          ],
        ),
      ),
    );
  }

  void _ensureAtLeastOneSelected() {
    if (!_isDogOwnerSelected && !_isDogSitterSelected) {
      _isDogOwnerSelected = true;
    }
  }

  void _updateFilterSettings(UserProfileState userProfileState) {
    userProfileState.updateFilterSettings(
      filterLookingForDogOwner: _isDogOwnerSelected,
      filterLookingForDogSitter: _isDogSitterSelected,
      filterDistance: _currentDistanceValue,
    );
  }
}
