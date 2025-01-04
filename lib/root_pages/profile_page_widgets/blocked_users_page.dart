// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// This function shows an unblock confirmation dialog using the same
/// design as your other dialogs. If the user confirms, it calls `onConfirm()`.
void showUnblockConfirmationDialog(
  BuildContext context,
  String userName,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.popUpRadius),
          side: const BorderSide(
            color: AppColors.customBlack,
            width: 3.0,
          ),
        ),
        title: const Center(
          child: Text(
            'Are you sure?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.customBlack,
            ),
          ),
        ),
        content: Text(
          'Unblocking $userName will allow them to see your profile and contact you again.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.customBlack,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // "No" Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bg,
                    side: const BorderSide(
                      color: AppColors.customBlack,
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                    ),
                  ),
                ),
                // "Yes" Button
                ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.customBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.bg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({Key? key}) : super(key: key);

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<String> _blockedUserIds = [];
  final Map<String, Map<String, dynamic>> _userProfiles = {};
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchBlockedUsers();
  }

  @override
  void dispose() {
    // Dispose all animation and scroll controllers
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Fetches all blocked users for the current user.
  Future<void> _fetchBlockedUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final blockedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('blockedUsers')
          .get();

      final blockedIds = <String>[];
      for (var doc in blockedSnapshot.docs) {
        blockedIds.add(doc.id);
      }

      if (mounted) {
        setState(() {
          _blockedUserIds = blockedIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching blocked users: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fetch the user profile data for a blocked user, if we haven't already
  void _fetchUserProfile(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            _userProfiles[userId] = userDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      developer.log('Error fetching user profile: $e');
    }
  }

  /// Removes the given user ID from the "blockedUsers" collection.
  Future<void> _unblockUser(String blockedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('blockedUsers')
          .doc(blockedUserId)
          .delete();

      // Once unblocked, remove from our local list as well
      setState(() {
        _blockedUserIds.remove(blockedUserId);
      });
    } catch (e) {
      developer.log('Error unblocking user: $e');
    }
  }

  /// Builds each row for a blocked user.
  Widget _buildBlockedUserItem(String userId) {
    // Default placeholders
    String profileImageUrl = UserProfileState.placeholderImageUrl;
    String userName = 'Anonymous';
    bool isDogOwner = false;
    String dogName = '';

    // If we have the user data, use it
    if (_userProfiles.containsKey(userId)) {
      final userProfile = _userProfiles[userId]!;
      final images = List<String>.from(userProfile['images'] ?? []);
      if (images.isNotEmpty) {
        profileImageUrl = images[0];
      }
      userName = userProfile['userName'] ?? 'Anonymous';
      isDogOwner = userProfile['isDogOwner'] ?? false;
      dogName = userProfile['dogName'] ?? '';
    } else {
      // Otherwise fetch it now
      _fetchUserProfile(userId);
    }

    // Auto-scrolling setup
    final String controllerKey = userId;
    if (!_scrollControllers.containsKey(controllerKey)) {
      _scrollControllers[controllerKey] = ScrollController();
      _animationControllers[controllerKey] = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5),
      );

      final animation = Tween<double>(begin: 0.0, end: 1.0)
          .animate(_animationControllers[controllerKey]!);

      animation.addListener(() {
        if (_scrollControllers[controllerKey]!.hasClients) {
          _scrollControllers[controllerKey]!.jumpTo(
            animation.value *
                _scrollControllers[controllerKey]!.position.maxScrollExtent,
          );
        }
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_scrollControllers[controllerKey]!.hasClients) {
              _scrollControllers[controllerKey]!.jumpTo(0);
              _animationControllers[controllerKey]!.forward(from: 0.0);
            }
          });
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationControllers[controllerKey]!.forward();
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 9.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.customBlack, width: 2),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(profileImageUrl),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            // Username and dog name with auto-scrolling
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollControllers[controllerKey],
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 20, color: AppColors.customBlack),
                    const SizedBox(width: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.customBlack,
                      ),
                    ),
                    if (isDogOwner) ...[
                      const SizedBox(width: 4),
                      const Text(
                        " • ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.customBlack,
                        ),
                      ),
                      const Icon(
                        Icons.pets_rounded,
                        size: 18,
                        color: AppColors.customBlack,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dogName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.customBlack,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // More-Vert Icon -> "Unblock"
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.customBlack,
                size: 24,
              ),
              onSelected: (String value) {
                if (value == 'unblock') {
                  // Show the confirmation dialog
                  showUnblockConfirmationDialog(
                    context,
                    userName,
                    () async {
                      await _unblockUser(userId);
                    },
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'unblock',
                  child: Center(
                    child: Text(
                      'Unblock',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: AppColors.customBlack,
                      ),
                    ),
                  ),
                ),
              ],
              offset: const Offset(-10, 40),
              color: AppColors.bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.popUpRadius),
                side: const BorderSide(
                  color: AppColors.customBlack,
                  width: 3.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main build method for the page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLightest,
      appBar: AppBar(
        title: const Text(
          'Blocked Users',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.customBlack,
          ),
        ),
        backgroundColor: AppColors.greyLightest,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.greyLightest,
              borderRadius: BorderRadius.circular(UIConstants.outerRadius),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_circle_left_rounded),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.customBlack,
              iconSize: 30.0,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _blockedUserIds.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "You have not blocked any users. Blocked users will be shown here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.customBlack,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _blockedUserIds.length,
                  itemBuilder: (context, index) {
                    return _buildBlockedUserItem(_blockedUserIds[index]);
                  },
                ),
    );
  }
}
