import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/constants/colors.dart';
import 'package:intl/intl.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _birthdayController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _dogNameController;
  late TextEditingController _dogBreedController;
  late TextEditingController _dogAgeController;
  bool _isLoadingLocation = false;
  late DateTime _selectedBirthday;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.userName);
    _selectedBirthday = widget.profile.userBirthday;
    _birthdayController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(_selectedBirthday));
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
    _birthdayController.dispose();
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
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      String location = '${place.locality}, ${place.country}';

      setState(() {
        _locationController.text = location;
      });
    } catch (e) {
      log('Error fetching location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  int _calculateAge(DateTime birthday) {
    DateTime now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectBirthday(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
              controller: _birthdayController,
              decoration: const InputDecoration(labelText: 'Birthday'),
              readOnly: true,
              onTap: () => _selectBirthday(context),
            ),
            if (_selectedBirthday != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child:
                    Text('Current Age: ${_calculateAge(_selectedBirthday!)}'),
              ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                suffixIcon: _isLoadingLocation
                    ? Transform.scale(
                        scale: 0.4,
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
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
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
            final updatedLocation = _locationController.text;
            final updatedAbout = _aboutController.text;
            final updatedDogName = _dogNameController.text;
            final updatedDogBreed = _dogBreedController.text;
            final updatedDogAge =
                int.tryParse(_dogAgeController.text) ?? widget.profile.dogAge;

            Provider.of<UserProfileState>(context, listen: false)
                .updateUserProfile(
              name: updatedName,
              userBirthday: _selectedBirthday,
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
