import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class OtherPersons extends StatefulWidget {
  final Function(UserProfile, String)
      onProfileSelected; // Callback to notify profile selection

  const OtherPersons({super.key, required this.onProfileSelected});

  @override
  // ignore: library_private_types_in_public_api
  _OtherPersonsState createState() => _OtherPersonsState();
}

class _OtherPersonsState extends State<OtherPersons>
    with TickerProviderStateMixin {
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
      developer.log('Error fetching users: $e');
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
    final double selectedFilterDistance =
        userProfileState.userProfile.filterDistance;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredUsers = _users.where((user) {
      final firestoreData = user['firestoreData'];
      final bool isDogOwner = firestoreData['isDogOwner'] == true;

      final String uid = user['uid'];
      if (uid == _authService.getCurrentUserId()) {
        return false;
      }

      // Calculate the distance between the main user and the current user
      final double userLatitude = firestoreData['latitude'].toDouble();
      final double userLongitude = firestoreData['longitude'].toDouble();
      final double distance = _calculateDistance(
        userProfileState.userProfile.latitude,
        userProfileState.userProfile.longitude,
        userLatitude,
        userLongitude,
      );

      // Apply the filters: show based on owner/sitter selection and distance
      bool withinDistance = distance <= selectedFilterDistance;
      bool matchesFilter = (showDogOwner && showDogSitter) ||
          (showDogOwner && isDogOwner) ||
          (showDogSitter && !isDogOwner);

      return withinDistance && matchesFilter;
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text:
                'No users found 😔\n\nAdjust your filter settings\nand spread the word about ',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.0,
                fontWeight: FontWeight.normal,
                color: AppColors
                    .customBlack // Ensure to set the color to avoid defaulting to primary color
                ),
            children: <TextSpan>[
              TextSpan(
                text: 'DoggyMatch',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' 🐶❤️',
              ),
            ],
          ),
        ),
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
          uid: data['uid'],
          email: data['email'],
          userName: data['userName'],
          dogName: data['dogName'],
          dogBreed: data['dogBreed'],
          dogAge: data['dogAge'],
          isDogOwner: data['isDogOwner'],
          images: List<String>.from(data['images']),
          profileColor: Color(data['profileColor']),
          aboutText: data['aboutText'],
          location: data['location'],
          latitude: data['latitude'].toDouble(),
          longitude: data['longitude'].toDouble(),
          filterDistance: data['filterDistance'],
          birthday: data['birthday'] != null
              ? DateTime.parse(data['birthday'])
              : null,
        );

        // Calculate the distance
        final userProfileState =
            Provider.of<UserProfileState>(context, listen: false);
        final mainUserLatitude = userProfileState.userProfile.latitude;
        final mainUserLongitude = userProfileState.userProfile.longitude;
        final distance = _calculateDistance(
          mainUserLatitude,
          mainUserLongitude,
          selectedProfile.latitude,
          selectedProfile.longitude,
        ).toStringAsFixed(1);

        // Call the callback to notify SearchPage
        widget.onProfileSelected(selectedProfile, distance);
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
            _buildUserFooter(data['userName'], data['latitude'].toDouble(),
                data['longitude'].toDouble()),
          ],
        ),
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

  Widget _buildDogOwnerHeader(String dogName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
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
          Expanded(
            child: _ScrollableText(
              text: dogName,
              prefixIconSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserFooter(
      String userName, double userLatitude, double userLongitude) {
    // Get the main user's latitude and longitude from UserProfileState
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final mainUserLatitude = userProfileState.userProfile.latitude;
    final mainUserLongitude = userProfileState.userProfile.longitude;

    // Calculate the distance
    final distance = _calculateDistance(
      mainUserLatitude,
      mainUserLongitude,
      userLatitude,
      userLongitude,
    ).toStringAsFixed(1);

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
            child: _ScrollableText(
              text: userName,
              prefixIconSize: 18,
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

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the Earth in kilometers
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in kilometers
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}

class _ScrollableText extends StatefulWidget {
  final String text;
  final IconData? prefixIcon;
  final double? prefixIconSize;

  // ignore: use_super_parameters
  const _ScrollableText({
    Key? key,
    required this.text,
    // ignore: unused_element
    this.prefixIcon,
    this.prefixIconSize,
  }) : super(key: key);

  @override
  __ScrollableTextState createState() => __ScrollableTextState();
}

class __ScrollableTextState extends State<_ScrollableText>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_animationController)
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
              _animation.value * _scrollController.position.maxScrollExtent);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
              _animationController.forward(from: 0.0);
            }
          });
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (widget.prefixIcon != null)
            Icon(
              widget.prefixIcon,
              color: AppColors.customBlack,
              size: widget.prefixIconSize ?? 18,
            ),
          if (widget.prefixIcon != null) const SizedBox(width: 4.0),
          Text(
            widget.text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: AppColors.customBlack,
            ),
          ),
        ],
      ),
    );
  }
}
