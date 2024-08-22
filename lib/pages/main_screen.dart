import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/pages/search_page.dart';
import 'package:doggymatch_flutter/pages/chat_page.dart';
import 'package:doggymatch_flutter/pages/profile_page.dart';
import 'package:doggymatch_flutter/widgets/custom_bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SearchPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

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
