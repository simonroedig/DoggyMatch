import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _dogNameController;
  late TextEditingController _dogBreedController;
  late TextEditingController _dogAgeController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.userName);
    _ageController = TextEditingController(text: '${widget.profile.userAge}');
    _locationController = TextEditingController(text: widget.profile.location);
    _aboutController = TextEditingController(text: widget.profile.aboutText);
    _dogNameController = TextEditingController(text: widget.profile.dogName);
    _dogBreedController = TextEditingController(text: widget.profile.dogBreed);
    _dogAgeController =
        TextEditingController(text: widget.profile.dogAge?.toString() ?? '');
    _getCurrentLocation(); // Get location on initialization
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _dogNameController.dispose();
    _dogBreedController.dispose();
    _dogAgeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, show a message to the user.
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, show a message to the user.
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, show a message to the user.
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Get human-readable address from coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      String location = '${place.locality}, ${place.country}';

      setState(() {
        _locationController.text = location;
      });
    } catch (e) {
      // Handle the error appropriately in your app
      log('Error fetching location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                suffixIcon: _isLoadingLocation
                    ? Transform.scale(
                        scale: 0.4, // Adjust the scale to change the size
                        child: const CircularProgressIndicator(
                          strokeWidth: 6.0,
                          color: AppColors.customBlack,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: _getCurrentLocation,
                      ),
              ),
            ),
            TextField(
              controller: _aboutController,
              decoration: const InputDecoration(labelText: 'About'),
              maxLines: null, // Allows for multiline input
              keyboardType:
                  TextInputType.multiline, // Allows for multiline text input
              textInputAction: TextInputAction
                  .newline, // Adds a new line instead of submitting the form
            ),
            if (widget.profile.isDogOwner) ...[
              TextField(
                controller: _dogNameController,
                decoration: const InputDecoration(labelText: 'Dog Name'),
              ),
              TextField(
                controller: _dogBreedController,
                decoration: const InputDecoration(labelText: 'Dog Breed'),
              ),
              TextField(
                controller: _dogAgeController,
                decoration: const InputDecoration(labelText: 'Dog Age'),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedName = _nameController.text;
            final updatedAge =
                int.tryParse(_ageController.text) ?? widget.profile.userAge;
            final updatedLocation = _locationController.text;
            final updatedAbout = _aboutController.text;
            final updatedDogName = _dogNameController.text;
            final updatedDogBreed = _dogBreedController.text;
            final updatedDogAge =
                int.tryParse(_dogAgeController.text) ?? widget.profile.dogAge;

            Provider.of<UserProfileState>(context, listen: false)
                .updateUserProfile(
              name: updatedName,
              age: updatedAge,
              location: updatedLocation,
              aboutText: updatedAbout,
              dogName: widget.profile.isDogOwner ? updatedDogName : null,
              dogBreed: widget.profile.isDogOwner ? updatedDogBreed : null,
              dogAge: widget.profile.isDogOwner ? updatedDogAge : null,
            );

            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
