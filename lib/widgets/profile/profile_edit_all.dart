import 'dart:developer';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:doggymatch_flutter/colors.dart'; // Import your custom colors
import 'package:doggymatch_flutter/pages/main_screen.dart'; // Import MainScreen to navigate back

class ProfileImageEdit extends StatefulWidget {
  final UserProfile profile;
  final bool fromRegister;

  const ProfileImageEdit(
      {super.key, required this.profile, this.fromRegister = false});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileImageEditState createState() => _ProfileImageEditState();
}

class _ProfileImageEditState extends State<ProfileImageEdit> {
  late List<String> _images;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;
  late TextEditingController _dogNameController;
  late TextEditingController _dogBreedController;
  late TextEditingController _dogAgeController;
  DateTime? _selectedBirthday;
  bool _isLoadingLocation = false;
  bool _isUploadingImage = false; // Track image upload status

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
    _images = widget.profile.images
        .where((image) => image != UserProfileState.placeholderImageUrl)
        .toList();

    _nameController = TextEditingController(text: widget.profile.userName);
    _selectedBirthday = widget.profile.birthday;
    _locationController = TextEditingController(text: widget.profile.location);
    _aboutController = TextEditingController(text: widget.profile.aboutText);
    _dogNameController = TextEditingController(text: widget.profile.dogName);
    _dogBreedController = TextEditingController(text: widget.profile.dogBreed);
    _dogAgeController = TextEditingController(text: widget.profile.dogAge);

    _getCurrentLocation();

    // Add listeners to the text controllers to update the state when the text changes
    _nameController.addListener(() => setState(() {}));
    _aboutController.addListener(() => setState(() {}));
    _dogNameController.addListener(() => setState(() {}));
    _dogBreedController.addListener(() => setState(() {}));
    _dogAgeController.addListener(() => setState(() {}));
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

  Future<bool> _onWillPop() async {
    if (!_validateFields()) {
      _showValidationError();
      return false;
    }
    await _saveProfileInformation();
    return true;
  }

  bool _validateFields() {
    // Validate name
    if (_nameController.text.length < _minFieldLength) return false;

    // Validate birthday
    if (_selectedBirthday == null) return false;

    // Validate about section
    if (_aboutController.text.length < _minAboutLength) return false;

    // Validate dog information if the user is a dog owner
    if (widget.profile.isDogOwner) {
      if (_dogNameController.text.length < _minFieldLength) return false;
      if (_dogBreedController.text.length < _minFieldLength) return false;
      if (_dogAgeController.text.length < _minFieldLength) return false;
    }

    return true;
  }

  void _showValidationError() {
    String message =
        "Please fill out all required fields with the minimum required characters.";

    if (_selectedBirthday == null) {
      message = "Please select a birthday.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.customRed,
      ),
    );
  }

  Future<void> _saveProfileInformation() async {
    final updatedName = _nameController.text;
    final updatedLocation = _locationController.text;
    final updatedAbout = _aboutController.text;
    final updatedDogName = _dogNameController.text;
    final updatedDogBreed = _dogBreedController.text;
    final updatedDogAge = _dogAgeController.text;

    await Provider.of<UserProfileState>(context, listen: false)
        .updateUserProfile(
      name: updatedName,
      birthday: _selectedBirthday,
      location: updatedLocation,
      aboutText: updatedAbout,
      dogName: widget.profile.isDogOwner ? updatedDogName : null,
      dogBreed: widget.profile.isDogOwner ? updatedDogBreed : null,
      dogAge: widget.profile.isDogOwner ? updatedDogAge : null,
    );
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
                  ? AppColors.customRed
                  : AppColors.customBlack.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadImage() async {
    if (_images.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You can only have a maximum of 9 images")),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isUploadingImage = true; // Set loading state to true
      });

      final userId = _authService.getCurrentUserId();
      if (userId != null) {
        final downloadUrl =
            await _authService.uploadProfileImage(pickedFile.path, userId);
        if (downloadUrl != null && mounted) {
          setState(() {
            _images.add(downloadUrl);
            _isUploadingImage = false; // Set loading state to false
          });
          await _updateUserProfileImages();
        } else {
          setState(() {
            _isUploadingImage = false; // Set loading state to false on failure
          });
        }
      }
    }
  }

  Future<void> _deleteImage(int index) async {
    final imageUrl = _images[index];
    await _authService.deleteProfileImage(imageUrl);
    setState(() {
      _images.removeAt(index);
    });
    await _updateUserProfileImages();
  }

  Future<void> _updateUserProfileImages() async {
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    await userProfileState.updateUserProfileImages(_images);
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      final String image = _images.removeAt(oldIndex);
      _images.insert(newIndex, image);
    });
    _updateUserProfileImages();
  }

  @override
  Widget build(BuildContext context) {
    final isMaxImages = _images.length >= 9;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget
              .fromRegister, // Prevent default back button if fromRegister is true
          title: Align(
            alignment: widget.fromRegister
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: const Text(
              "Edit Profile",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: AppColors.greyLightest,
          elevation: 0.0, // Remove shadow
          scrolledUnderElevation: 0.0, // Prevent darkening on scroll
          surfaceTintColor:
              Colors.transparent, // Keep the background color consistent
          leading: widget.fromRegister
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_circle_left_rounded,
                    size: 30.0,
                    color: AppColors.customBlack,
                  ),
                  onPressed: () async {
                    if (await _onWillPop()) {
                      if (!mounted) {
                        return; // Check if the widget is still mounted
                      }
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              const MainScreen(fromRegister: false),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
          actions: widget.fromRegister
              ? [
                  IconButton(
                    icon: const Icon(
                      Icons
                          .arrow_circle_right_rounded, // Icon pointing to the right
                      size: 30.0,
                      color: AppColors.customBlack,
                    ),
                    onPressed: () async {
                      if (await _onWillPop()) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainScreen(fromRegister: false),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ]
              : null,
        ),
        backgroundColor: AppColors.greyLightest,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${_images.length}/9 Images Uploaded",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.0,
                  ),
                ),
              ),
              ReorderableGridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                padding: const EdgeInsets.all(8.0),
                itemCount: isMaxImages ? _images.length : _images.length + 1,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < _images.length && newIndex < _images.length) {
                    _reorderImages(oldIndex, newIndex);
                  }
                },
                itemBuilder: (context, index) {
                  if (index == _images.length && !isMaxImages) {
                    return _isUploadingImage
                        ? Container(
                            key: const ValueKey('uploading_indicator'),
                            decoration: BoxDecoration(
                              color: AppColors.customBlack.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: AppColors.customBlack,
                                width: 3.0,
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.customBlack,
                              ),
                            ),
                          )
                        : GestureDetector(
                            key: const ValueKey('add_image'),
                            onTap: _uploadImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.customBlack.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: AppColors.customBlack,
                                  width: 3.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate,
                                color: AppColors.customBlack,
                                size: 40.0,
                              ),
                            ),
                          );
                  } else if (index < _images.length) {
                    return Stack(
                      key: ValueKey(_images[index]),
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: AppColors.customBlack,
                                width: 3.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11.0),
                              child: _images[index].startsWith('http')
                                  ? Image.network(
                                      _images[index],
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      _images[index],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.customBlack,
                            ),
                            onPressed: () => _deleteImage(index),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
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
                      minLines: 1,
                      maxLines: null,
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
