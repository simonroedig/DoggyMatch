import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/pages/search_page.dart';
import 'package:doggymatch_flutter/pages/chat_page.dart';
import 'package:doggymatch_flutter/pages/profile_page.dart';
import 'package:doggymatch_flutter/widgets/custom_bottom_navigation.dart';
import 'package:doggymatch_flutter/profile/profile.dart';
import 'package:doggymatch_flutter/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  final Profile dogSitterProfile = DogSitterProfile(
    userName: 'Andi',
    userAge: 26,
    aboutText: 'I am a student in Munich looking for some dogs to walk with.',
    profileColor: AppColors.accent1,
    images: [
      'assets/icons/zz.png',
      'assets/icons/zz.png',
    ],
  );

  final Profile dogOwnerProfile = DogOwnerProfile(
    userName: 'Sara',
    userAge: 30,
    aboutText: 'I love my dog and am looking for a trustworthy sitter.',
    profileColor: AppColors.accent1,
    dogName: 'Buddy',
    dogBreed: 'Golden Retriever',
    dogAge: 5,
    images: [
      'assets/icons/zz.png',
      'assets/icons/zz.png',
    ],
  );

  @override
  void initState() {
    super.initState();
    _pages = [
      const SearchPage(),
      const ChatPage(),
      ProfilePage(profile: dogOwnerProfile), // Use the desired profile here
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        activeIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
