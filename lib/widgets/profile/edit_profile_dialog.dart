import 'dart:developer';
import 'dart:ui'; // Required for ImageFilter.blur

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _dogNameController;
  late TextEditingController _dogBreedController;
  late TextEditingController _dogAgeController;
  DateTime? _selectedBirthday;
  bool _isLoadingLocation = false;

  final int _minAboutLength = 10;
  final int _minFieldLength = 1;
  final int _maxNameLength = 50;
  final int _maxAboutLength = 800;
  final int _maxDogNameLength = 50;
  final int _maxDogBreedLength = 50;
  final int _maxDogAgeLength = 20;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.userName)
      ..addListener(() => setState(() {}));
    _selectedBirthday = widget.profile.birthday;
    _locationController = TextEditingController(text: widget.profile.location);
    _aboutController = TextEditingController(text: widget.profile.aboutText)
      ..addListener(() => setState(() {}));
    _dogNameController = TextEditingController(text: widget.profile.dogName)
      ..addListener(() => setState(() {}));
    _dogBreedController = TextEditingController(text: widget.profile.dogBreed)
      ..addListener(() => setState(() {}));
    _dogAgeController = TextEditingController(text: widget.profile.dogAge)
      ..addListener(() => setState(() {}));
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
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

      if (mounted) {
        setState(() {
          _locationController.text = location;
        });
      }
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

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Widget _buildHeadlineWithIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.customBlack),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.customBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithCounter({
    required TextEditingController controller,
    required int maxLength,
    required int minLength,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) _buildHeadlineWithIcon(icon, labelText),
        TextField(
          controller: controller,
          maxLength: maxLength,
          minLines: minLines,
          maxLines: maxLines,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
          ],
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.customBlack),
          decoration: InputDecoration(
            counterText: '${controller.text.length} / $maxLength',
            counterStyle: TextStyle(
              color: controller.text.length > maxLength ||
                      controller.text.length < minLength
                  ? Colors.red
                  : AppColors.customBlack.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  bool _isSaveEnabled() {
    if (_nameController.text.length < _minFieldLength ||
        _aboutController.text.length < _minAboutLength ||
        (widget.profile.isDogOwner &&
            (_dogNameController.text.length < _minFieldLength ||
                _dogBreedController.text.length < _minFieldLength ||
                _dogAgeController.text.length < _minFieldLength))) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
          child: Container(
            color: Colors.black
                .withOpacity(0.5), // Darkening the background slightly
          ),
        ),
        Center(
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'Poppins',
                  ),
            ),
            child: AlertDialog(
              title: const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.customBlack,
                  ),
                ),
              ),
              backgroundColor: AppColors.bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(
                  color: AppColors.customBlack,
                  width: 3,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextFieldWithCounter(
                      controller: _nameController,
                      maxLength: _maxNameLength,
                      minLength: _minFieldLength,
                      labelText: 'Name',
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildHeadlineWithIcon(Icons.access_time, 'Birthday'),
                    GestureDetector(
                      onTap: () => _selectBirthday(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: _selectedBirthday != null
                                ? DateFormat.yMd().format(_selectedBirthday!)
                                : '',
                          ),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.calendar_today,
                                color: AppColors.customBlack),
                          ),
                          style: const TextStyle(color: AppColors.customBlack),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHeadlineWithIcon(
                        Icons.location_on_rounded, 'Location'),
                    TextField(
                      controller: _locationController,
                      minLines: 1, // Add this line
                      maxLines: null, // Add this line
                      decoration: InputDecoration(
                        suffixIcon: _isLoadingLocation
                            ? Transform.scale(
                                scale: 0.4,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 6.0,
                                  color: AppColors.customBlack,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.location_on_rounded,
                                    color: AppColors.customBlack),
                                onPressed: _getCurrentLocation,
                              ),
                      ),
                      style: const TextStyle(color: AppColors.customBlack),
                    ),
                    const SizedBox(height: 16),
                    _buildTextFieldWithCounter(
                      controller: _aboutController,
                      maxLength: _maxAboutLength,
                      minLength: _minAboutLength,
                      labelText: 'About',
                      icon: Icons.info_outline_rounded,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: null,
                    ),
                    if (widget.profile.isDogOwner) ...[
                      const SizedBox(height: 16),
                      _buildTextFieldWithCounter(
                        controller: _dogNameController,
                        maxLength: _maxDogNameLength,
                        minLength: _minFieldLength,
                        labelText: 'Dog Name',
                        icon: Icons.pets_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFieldWithCounter(
                        controller: _dogBreedController,
                        maxLength: _maxDogBreedLength,
                        minLength: _minFieldLength,
                        labelText: 'Dog Breed',
                        icon: CupertinoIcons.heart_circle,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFieldWithCounter(
                        controller: _dogAgeController,
                        maxLength: _maxDogAgeLength,
                        minLength: _minFieldLength,
                        labelText: 'Dog Age',
                        icon: Icons.access_time,
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.customBlack),
                  ),
                ),
                TextButton(
                  onPressed: _isSaveEnabled()
                      ? () {
                          final updatedName = _nameController.text;
                          final updatedLocation = _locationController.text;
                          final updatedAbout = _aboutController.text;
                          final updatedDogName = _dogNameController.text;
                          final updatedDogBreed = _dogBreedController.text;
                          final updatedDogAge = _dogAgeController.text;

                          Provider.of<UserProfileState>(context, listen: false)
                              .updateUserProfile(
                            name: updatedName,
                            birthday: _selectedBirthday,
                            location: updatedLocation,
                            aboutText: updatedAbout,
                            dogName: widget.profile.isDogOwner
                                ? updatedDogName
                                : null,
                            dogBreed: widget.profile.isDogOwner
                                ? updatedDogBreed
                                : null,
                            dogAge: widget.profile.isDogOwner
                                ? updatedDogAge
                                : null,
                          );

                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _isSaveEnabled()
                          ? widget.profile.profileColor
                          : Colors.grey,
                      border:
                          Border.all(color: AppColors.customBlack, width: 3),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.customBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
