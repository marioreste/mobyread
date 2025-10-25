import 'package:flutter/material.dart';
import 'reading_screen.dart';
import 'home_screen.dart';
import 'finished_screen.dart';
import '../widgets/bottom_nav.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final PageController _pageController = PageController(initialPage: 1); // start on Home
  int _currentIndex = 1;

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentIndex = index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView provides swipe navigation
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          ReadingScreen(),
          HomeScreen(),
          FinishedScreen(),
        ],
        physics: const ClampingScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex, onTap: _onNavTap),
    );
  }
}
