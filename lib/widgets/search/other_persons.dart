import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class OtherPersons extends StatefulWidget {
  final Function(UserProfile)
      onProfileSelected; // Callback to notify profile selection

  const OtherPersons({super.key, required this.onProfileSelected});

  @override
  _OtherPersonsState createState() => _OtherPersonsState();
}

class _OtherPersonsState extends State<OtherPersons> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      List<Map<String, dynamic>> users =
          await _authService.fetchAllUsersWithDocuments();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error fetching users: $e');
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = Provider.of<UserProfileState>(context);
    final bool showDogOwner =
        userProfileState.userProfile.filterLookingForDogOwner;
    final bool showDogSitter =
        userProfileState.userProfile.filterLookingForDogSitter;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredUsers = _users.where((user) {
      final firestoreData = user['firestoreData'];
      final bool isDogOwner = firestoreData['isDogOwner'] == true;

      if (showDogOwner && showDogSitter) {
        return true; // Show all users
      } else if (showDogOwner) {
        return isDogOwner; // Show only dog owners
      } else if (showDogSitter) {
        return !isDogOwner; // Show only dog sitters
      } else {
        return false; // If no filters are selected, show nothing (this shouldn't happen due to UI logic)
      }
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: GridView.builder(
        padding: const EdgeInsets.all(18.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 0.68,
        ),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          final firestoreData = user['firestoreData'];
          final bool isDogOwner = firestoreData['isDogOwner'] == true;
          final profileColor =
              Color(firestoreData['profileColor'] ?? 0xFFFFFFFF);
          final filterDistance =
              firestoreData['filterDistance']?.toStringAsFixed(1) ?? '0';

          return _buildUserCard(
              firestoreData, isDogOwner, profileColor, filterDistance);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> data, bool isDogOwner,
      Color profileColor, String filterDistance) {
    return GestureDetector(
      onTap: () {
        // Create a UserProfile instance from the data map
        UserProfile selectedProfile = UserProfile(
          userName: data['userName'],
          dogName: data['dogName'],
          isDogOwner: data['isDogOwner'],
          images: List<String>.from(data['images']),
          profileColor: Color(data['profileColor']),
          aboutText: data['aboutText'],
          location: data['location'],
          filterDistance: data['filterDistance'],
          birthday: data['birthday'] != null
              ? DateTime.parse(data['birthday'])
              : null,
        );

        // Call the callback to notify SearchPage
        widget.onProfileSelected(selectedProfile);
      },
      child: Container(
        decoration: BoxDecoration(
          color: profileColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppColors.customBlack, width: 3),
        ),
        child: Column(
          children: [
            if (isDogOwner) _buildDogOwnerHeader(data['dogName']),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(isDogOwner ? 0 : 21.0),
                ),
                child: _buildUserImage(data['images'], isDogOwner),
              ),
            ),
            _buildUserFooter(data['userName'], filterDistance),
          ],
        ),
      ),
    );
  }

  Widget _buildDogOwnerHeader(String dogName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pets_rounded,
            color: AppColors.customBlack,
            size: 18,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              dogName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.customBlack,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserImage(List<dynamic> images, bool isDogOwner) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0),
      decoration: BoxDecoration(
        border: Border(
          top: isDogOwner
              ? const BorderSide(color: AppColors.customBlack, width: 3)
              : BorderSide.none,
          bottom: const BorderSide(color: AppColors.customBlack, width: 3),
        ),
      ),
      child: Image.network(
        images[0],
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildUserFooter(String userName, String distance) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.person_rounded,
            color: AppColors.customBlack,
            size: 18,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              userName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.customBlack,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$distance km',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
              fontFamily: 'Poppins',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
