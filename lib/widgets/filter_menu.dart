import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/notifiers/filter_notifier.dart';

class FilterMenu extends StatefulWidget {
  const FilterMenu({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  FilterMenuState createState() => FilterMenuState();
}

class FilterMenuState extends State<FilterMenu> {
  late double _currentDistanceValue;
  late bool _isDogOwnerSelected;
  late bool _isDogSitterSelected;
  late int _currentLastOnlineIndex;

  final List<String> _lastOnlineOptions = [
    "Anytime",
    "< 1 day ago",
    "< 3 days ago",
    "< 1 week ago",
    "< 1 month ago",
  ];

  @override
  void initState() {
    super.initState();
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    _currentDistanceValue = userProfileState.userProfile.filterDistance;
    _isDogOwnerSelected = userProfileState.userProfile.filterLookingForDogOwner;
    _isDogSitterSelected =
        userProfileState.userProfile.filterLookingForDogSitter;

    // Convert saved integer to an index for the _lastOnlineOptions list
    _currentLastOnlineIndex =
        (userProfileState.userProfile.filterLastOnline - 1)
            .clamp(0, _lastOnlineOptions.length - 1);
  }

  void _applyChanges() {
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);

    // Save the selected index + 1 as the integer value
    userProfileState.updateFilterSettings(
      filterLookingForDogOwner: _isDogOwnerSelected,
      filterLookingForDogSitter: _isDogSitterSelected,
      filterDistance: _currentDistanceValue,
      filterLastOnline: _currentLastOnlineIndex + 1,
    );
    Provider.of<FilterNotifier>(context, listen: false).notifyFilterChanged();
    widget.onClose(); // Notify parent that the menu is closing
  }

  void _toggleLastOnline() {
    setState(() {
      _currentLastOnlineIndex =
          (_currentLastOnlineIndex + 1) % _lastOnlineOptions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: AppColors.bg, // Set the background color for the sides
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 17.0), // Adjust padding for left and right
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: _calculateHeight(context),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                        });
                      },
                    ),
                    const SizedBox(height: 26),
                    Text(
                      _currentDistanceValue >= 30
                          ? "Distance > 30 km"
                          : _currentDistanceValue <= 0.1
                              ? "Distance < 0.1 km"
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
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      "Last Online",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.customBlack,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Center(
                      child: GestureDetector(
                        onTap: _toggleLastOnline,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: AppColors.greyLightest,
                            borderRadius: BorderRadius.circular(50.0),
                            border: Border.all(
                              color: AppColors.customBlack,
                              width: 3.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Center(
                            child: Text(
                              _lastOnlineOptions[_currentLastOnlineIndex],
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.customBlack,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: _applyChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.customBlack, // Button color
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0, // Increase the vertical padding
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Curved edges
                            side: const BorderSide(
                              color: AppColors.customBlack, // Border color
                              width: 3.0, // Border width
                            ),
                          ),
                          //elevation: 0, // No shadow
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold, // Bold font weight
                            color: AppColors.bg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateHeight(BuildContext context) {
    // Calculate height based on the screen height and some factor to match the ProfileWidget's height
    double baseHeight = MediaQuery.of(context).size.height;
    return baseHeight * 0.9; // Adjust the factor as necessary
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
}
