import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';

class FilterMenu extends StatefulWidget {
  const FilterMenu({super.key});

  @override
  FilterMenuState createState() => FilterMenuState();
}

class FilterMenuState extends State<FilterMenu> {
  double _currentDistanceValue = 0.1; // Initial distance value

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
          borderRadius: BorderRadius.circular(35.0),
          border: Border.all(
            color: AppColors.customBlack,
            width: 3.0,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Settings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.customBlack,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            Slider(
              thumbColor: AppColors.pastelPurple,
              activeColor: AppColors.pastelPurple,
              // color for the slider's track
              inactiveColor: AppColors.pastelPurple,

              value: _currentDistanceValue,
              min: 0.1,
              max: 30.0,
              divisions: 300, // Dividing the range to allow finer adjustments
              label: _currentDistanceValue.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  _currentDistanceValue = value;
                });
              },
            ),
            Text(
              // if the value smaller than 0.3, show "Nearby", else show the distance
              // if the value is larger than 30, show "Distance: >30 km"
              _currentDistanceValue >= 30
                  ? "Distance: >30 km"
                  : _currentDistanceValue <= 0.1
                      ? "Distance: <0.1 km"
                      : "Distance: ${_currentDistanceValue.toStringAsFixed(1)} km",

              style: const TextStyle(
                fontSize: 18,
                color: AppColors.customBlack,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
