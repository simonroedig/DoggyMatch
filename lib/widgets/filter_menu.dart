import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/colors.dart';

class FilterMenu extends StatefulWidget {
  final VoidCallback onFilterClose; // Callback to notify filter close

  const FilterMenu({super.key, required this.onFilterClose});

  @override
  FilterMenuState createState() => FilterMenuState();
}

class FilterMenuState extends State<FilterMenu> {
  late double _tempDistanceValue;
  late bool _tempIsDogOwnerSelected;
  late bool _tempIsDogSitterSelected;
  late UserProfileState userProfileState; // Cache the UserProfileState

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the UserProfileState during initialization
    userProfileState = Provider.of<UserProfileState>(context, listen: false);
    _tempDistanceValue = userProfileState.userProfile.filterDistance;
    _tempIsDogOwnerSelected =
        userProfileState.userProfile.filterLookingForDogOwner;
    _tempIsDogSitterSelected =
        userProfileState.userProfile.filterLookingForDogSitter;
  }

  @override
  Widget build(BuildContext context) {
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
              isSelected: _tempIsDogOwnerSelected,
              onTap: () {
                setState(() {
                  _tempIsDogOwnerSelected = !_tempIsDogOwnerSelected;
                  _ensureAtLeastOneSelected();
                });
              },
            ),
            const SizedBox(height: 10.0),
            _buildSelectionMenu(
              icon: Icons.person_rounded,
              text: "Dog Sitter",
              isSelected: _tempIsDogSitterSelected,
              onTap: () {
                setState(() {
                  _tempIsDogSitterSelected = !_tempIsDogSitterSelected;
                  _ensureAtLeastOneSelected();
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              _tempDistanceValue >= 30
                  ? "Distance >30 km"
                  : _tempDistanceValue <= 0.1
                      ? "Distance <0.1 km"
                      : "Distance ${_tempDistanceValue.toStringAsFixed(1)} km",
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
                    value: _tempDistanceValue,
                    min: 0.1,
                    max: 30.0,
                    divisions: 300,
                    onChanged: (double value) {
                      setState(() {
                        _tempDistanceValue = value;
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
    if (!_tempIsDogOwnerSelected && !_tempIsDogSitterSelected) {
      _tempIsDogOwnerSelected = true;
    }
  }

  // Function to update the filter settings in UserProfileState
  void applyFilterSettings() {
    userProfileState.updateTempFilterSettings(
      filterLookingForDogOwner: _tempIsDogOwnerSelected,
      filterLookingForDogSitter: _tempIsDogSitterSelected,
      filterDistance: _tempDistanceValue,
    );
  }

  @override
  void dispose() {
    applyFilterSettings(); // Apply the filter settings before disposing of the widget
    super.dispose();
  }
}
