import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/constants/colors.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_img_fullscreen.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';

class ProfileWidget extends StatefulWidget {
  final UserProfile profile;

  const ProfileWidget({super.key, required this.profile});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _buildProfileContainer(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildImageStack(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildUserInfoSection(),
                        if (widget.profile.isDogOwner) _buildDogInfoSection(),
                        _buildAboutSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Profile Container
  Widget _buildProfileContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: widget.profile.profileColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppColors.customBlack,
          width: 3.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21.0),
        child: child,
      ),
    );
  }

  // Image Stack
  Widget _buildImageStack() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openFullScreenImageView(context),
          child: _buildProfileImageSlider(),
        ),
        Positioned(
          bottom: 8.0,
          left: 0,
          right: 0,
          child: _buildImageIndicator(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 3.0,
            color: AppColors.customBlack,
          ),
        ),
      ],
    );
  }

  // Header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              widget.profile.isDogOwner
                  ? Icons.pets_rounded
                  : Icons.person_rounded,
              color: AppColors.customBlack,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.profile.isDogOwner ? 'Dog Owner' : 'Dog Sitter',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.customBlack,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.border_color_rounded,
              color: AppColors.customBlack),
          onPressed: () {
            _openEditProfileDialog(context);
          },
        ),
      ],
    );
  }

  // Profile Image Slider
  Widget _buildProfileImageSlider() {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount:
            widget.profile.images.isEmpty ? 1 : widget.profile.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = widget.profile.images.isNotEmpty
              ? widget.profile.images[index]
              : 'assets/icons/placeholder.png';

          return Image.asset(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  // Image Indicator (Circles)
  Widget _buildImageIndicator() {
    final int imageCount =
        widget.profile.images.isEmpty ? 1 : widget.profile.images.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(imageCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.customBlack,
              width: 2.0,
            ),
            shape: BoxShape.circle,
            color: Colors.white
                .withOpacity(_currentImageIndex == index ? 1.0 : 0.5),
          ),
        );
      }),
    );
  }

  // Full Screen Image View
  void _openFullScreenImageView(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FullScreenImageView(
        images: widget.profile.images.isNotEmpty
            ? widget.profile.images
            : ['assets/icons/placeholder.png'],
        initialIndex: _currentImageIndex,
      ),
    ));
  }

  // User Info Section
  Widget _buildUserInfoSection() {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.person_rounded,
            text: widget.profile.userName,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.access_time,
            text: '${widget.profile.userBirthday}',
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            text: widget.profile.location,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.social_distance_rounded,
            text: widget.profile.distance,
          ),
        ],
      ),
    );
  }

  // Dog Info Section
  Widget _buildDogInfoSection() {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.pets_rounded,
            text: widget.profile.dogName ?? '',
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: CupertinoIcons.heart_circle,
            text: widget.profile.dogBreed ?? '',
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.access_time,
            text: '${widget.profile.dogAge ?? ''} years old',
          ),
        ],
      ),
    );
  }

  // About Section
  Widget _buildAboutSection() {
    return _buildInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoHeader(
            icon: Icons.info_outline_rounded,
            title: 'About',
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.profile.aboutText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.customBlack,
            ),
          ),
        ],
      ),
    );
  }

  // Info Container (Root)
  Widget _buildInfoContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: AppColors.customBlack,
          width: 3.0,
        ),
      ),
      child: child,
    );
  }

  // Info Row (Icon and Text, e.g. Breed: Golden Retriever)
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.customBlack),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.customBlack,
          ),
        ),
      ],
    );
  }

  // Open Edit Profile Dialog
  void _openEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return EditProfileDialog(profile: widget.profile);
      },
    );
  }
}

// Info Header class moved out of ProfileWidgetState class
class _InfoHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _InfoHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.customBlack),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.customBlack,
          ),
        ),
      ],
    );
  }
}

// Edit Profile Dialog
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.userName);
    _ageController =
        TextEditingController(text: '${widget.profile.userBirthday}');
    _locationController = TextEditingController(text: widget.profile.location);
    _aboutController = TextEditingController(text: widget.profile.aboutText);
    _dogNameController = TextEditingController(text: widget.profile.dogName);
    _dogBreedController = TextEditingController(text: widget.profile.dogBreed);
    _dogAgeController =
        TextEditingController(text: widget.profile.dogAge?.toString() ?? '');
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
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _aboutController,
              decoration: const InputDecoration(labelText: 'About'),
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
            final updatedUserBirthday =
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
              userBirthday: updatedUserBirthday,
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
