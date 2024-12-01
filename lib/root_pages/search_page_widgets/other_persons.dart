import 'dart:developer' as developer;
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/friend_and_save_icon.dart';
import 'package:doggymatch_flutter/services/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/services/auth_service.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/notifiers/filter_notifier.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/shared_helper/icon_helpers.dart';

class OtherPersons extends StatefulWidget {
  final Function(UserProfile, String, String, bool)
      onProfileSelected; // Callback to notify profile selection
  final bool showAllProfiles;
  final bool showSavedProfiles;
  final bool showFriendProfiles;
  final bool showReceivedFriendRequestProfiles;
  final bool showSentFriendRequestProfiles;

  const OtherPersons(
      {super.key,
      required this.onProfileSelected,
      this.showAllProfiles = true,
      this.showSavedProfiles = false,
      this.showFriendProfiles = false,
      this.showReceivedFriendRequestProfiles = false,
      this.showSentFriendRequestProfiles = false});

  @override
  // ignore: library_private_types_in_public_api
  _OtherPersonsState createState() => _OtherPersonsState();
}

class _OtherPersonsState extends State<OtherPersons>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _authProfile = ProfileService();
  final FriendsService _friendsService = FriendsService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  late FilterNotifier _filterNotifier; // Add a state variable for the notifier

  final iconHelpers = IconHelpers();

  @override
  void initState() {
    super.initState();
    if (widget.showAllProfiles) {
      _filterNotifier = Provider.of<FilterNotifier>(context,
          listen: false); // Initialize in initState
      _filterNotifier
          .addListener(_loadFilteredUsers); // Add listener in initState
      _loadFilteredUsers();
    } else if (widget.showSavedProfiles) {
      _loadSavedUsers();
    } else if (widget.showFriendProfiles) {
      _loadFriendProfiles();
    } else if (widget.showReceivedFriendRequestProfiles) {
      _loadReceivedFriendRequestProfiles();
    } else if (widget.showSentFriendRequestProfiles) {
      _loadSentFriendRequestProfiles();
    }
  }

  @override
  void dispose() {
    if (widget.showAllProfiles) {
      _filterNotifier.removeListener(
          _loadFilteredUsers); // Remove listener safely in dispose
    }
    super.dispose();
  }

  Future<void> _loadFilteredUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true; // Show progress indicator
      });
    }
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final String? currentUserId =
        _authService.getCurrentUserId(); // Get the current user's UID

    try {
      List<Map<String, dynamic>> users =
          await _authProfile.fetchAllUsersWithinFilter(
        userProfileState.userProfile.filterLookingForDogOwner,
        userProfileState.userProfile.filterLookingForDogSitter,
        userProfileState.userProfile.filterDistance,
        userProfileState.userProfile.latitude,
        userProfileState.userProfile.longitude,
        userProfileState.userProfile.filterLastOnline,
      );

      // Exclude the current user's profile from the list
      users = users.where((user) => user['uid'] != currentUserId).toList();

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      developer.log('Error fetching filtered users: $e');
    }
  }

  // load saved users
  Future<void> _loadSavedUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true; // Show progress indicator
      });
    }

    try {
      List<Map<String, dynamic>> users =
          await _authProfile.fetchSavedUserProfiles();

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      developer.log('Error fetching saved users: $e');
    }
  }

  // load friend profiles
  Future<void> _loadFriendProfiles() async {
    if (mounted) {
      setState(() {
        _isLoading = true; // Show progress indicator
      });
    }
    try {
      List<Map<String, dynamic>> users =
          await _friendsService.fetchAllFriends();

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      developer.log('Error fetching friend profiles: $e');
    }
  }

  // load received friend request profiles
  Future<void> _loadReceivedFriendRequestProfiles() async {
    if (mounted) {
      setState(() {
        _isLoading = true; // Show progress indicator
      });
    }

    try {
      List<Map<String, dynamic>> users =
          await _friendsService.fetchAllFriendRequestReceived();

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      developer.log('Error fetching received friend request profiles: $e');
    }
  }

  // load sent friend request profiles
  Future<void> _loadSentFriendRequestProfiles() async {
    if (mounted) {
      setState(() {
        _isLoading = true; // Show progress indicator
      });
    }

    try {
      List<Map<String, dynamic>> users =
          await _friendsService.fetchAllFriendRequestSent();

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      developer.log('Error fetching sent friend request profiles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final onRefreshCallback = widget.showAllProfiles
        ? _loadFilteredUsers
        : widget.showSavedProfiles
            ? _loadSavedUsers
            : widget.showFriendProfiles
                ? _loadFriendProfiles
                : widget.showReceivedFriendRequestProfiles
                    ? _loadReceivedFriendRequestProfiles
                    : widget.showSentFriendRequestProfiles
                        ? _loadSentFriendRequestProfiles
                        : null; // Fallback if none of the conditions are true

    final noUsersTextCallback = widget.showAllProfiles
        ? 'No users found 😔\n\nAdjust your filter settings\nand spread the word about '
        : widget.showSavedProfiles
            ? 'No saved profiles found 😔\n\nSave profiles to view them here'
            : widget.showFriendProfiles
                ? 'No friends found 😔\n\nAdd friends to view them here'
                : widget.showReceivedFriendRequestProfiles
                    ? 'No received friend requests found 😔\n\nCheck back later for requests'
                    : widget.showSentFriendRequestProfiles
                        ? 'No sent friend requests found 😔\n\nSend requests to view them here'
                        : ''; // Fallback if none of the conditions are true

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: noUsersTextCallback,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.0,
              fontWeight: FontWeight.normal,
              color: AppColors.customBlack,
            ),
            children: const <TextSpan>[
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

    // GRID of the OTHERPERSONS
    return RefreshIndicator(
      onRefresh: onRefreshCallback ?? () async {},
      color: AppColors.customBlack,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 0.0, // Set the vertical padding
          horizontal: 16.0, // Set the horizontal padding
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.68,
        ),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
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

  Future<Map<String, dynamic>> _getUserStatus(String uid) async {
    bool isSaved = await _authProfile.isProfileSaved(uid);
    String friendStatus = await determineFriendStatus(uid);
    return {
      'isSaved': isSaved,
      'friendStatus': friendStatus,
    };
  }

  Widget _buildUserCard(Map<String, dynamic> data, bool isDogOwner,
      Color profileColor, String filterDistance) {
    // Calculate the distance
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    final mainUserLatitude = userProfileState.userProfile.latitude;
    final mainUserLongitude = userProfileState.userProfile.longitude;
    final distance = calculateDistance(
      mainUserLatitude,
      mainUserLongitude,
      data['latitude'].toDouble(),
      data['longitude'].toDouble(),
    ).toStringAsFixed(1);

    return GestureDetector(
      onTap: () async {
        developer.log('PERSONS Selected Profile UID: ${data['uid']}');
        developer.log('PERSONS Selected Profile Data: $data');
        developer.log('Own UID: ${_authService.getCurrentUserId()}');

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          useRootNavigator: true,
        );

        try {
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
            lastOnline: data['lastOnline'] != null
                ? DateTime.parse(data['lastOnline'])
                : null,
            filterLastOnline: data['filterLastOnline'] ?? 3,
          );

          // Log the selected profile's userName
          developer.log(
              'PERSONS Selected Profile UserName: ${selectedProfile.userName}');

          final lastOnline =
              calculateLastOnlineLong(selectedProfile.lastOnline);

          // Fetch the actual saved status
          bool isSaved = await _authProfile.isProfileSaved(data['uid']);

          // Call the callback to notify SearchPage
          widget.onProfileSelected(
              selectedProfile, distance, lastOnline, isSaved);
        } finally {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop(); // Pop the dialog
          }
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: profileColor,
              borderRadius: BorderRadius.circular(UIConstants.outerRadius),
              border: Border.all(color: AppColors.customBlack, width: 3),
            ),
            child: Column(
              children: [
                if (isDogOwner) _buildDogOwnerHeader(data['dogName']),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                          isDogOwner ? 0 : UIConstants.outerRadiusClipped),
                    ),
                    child: _buildUserImage(data['images'], isDogOwner),
                  ),
                ),
                _buildUserFooter(data['userName'], data['latitude'].toDouble(),
                    data['longitude'].toDouble()),
              ],
            ),
          ),
          // Friend status icon using FriendIconWidget
          Positioned(
            bottom: 40, // Adjust position as needed
            left: 10,
            child: FriendIconWidget(
              userId: data['uid'],
              profileColor: profileColor,
            ),
          ),
          // Save icon using SaveIconWidget
          Positioned(
            bottom: 40,
            right: 10,
            child: SaveIconWidget(
              userId: data['uid'],
              profileColor: profileColor,
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('Error'),
          );
        },
      ),
    );
  }

  Future<String> determineFriendStatus(String profileUid) async {
    if (await _friendsService.areFriends(profileUid)) {
      return 'friends';
    } else if (await _friendsService.isFriendRequestReceived(profileUid)) {
      return 'received';
    } else if (await _friendsService.isFriendRequestSent(profileUid)) {
      return 'sent';
    }
    return 'none';
  }

  Widget _buildDogOwnerHeader(String dogName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Center(
        // Ensures content is centered within the Row
        child: Row(
          mainAxisSize: MainAxisSize.min, // Adjusts to the size of the content
          children: [
            const Icon(
              Icons.pets_rounded,
              color: AppColors.customBlack,
              size: 18,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: _ScrollableText(
                text: dogName,
                prefixIconSize: 18,
              ),
            ),
          ],
        ),
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
    final distance = calculateDistance(
      mainUserLatitude,
      mainUserLongitude,
      userLatitude,
      userLongitude,
    ).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
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
