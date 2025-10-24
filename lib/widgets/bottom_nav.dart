import 'package:flutter/material.dart';
import '../screens/reading_screen.dart';
import '../screens/home_screen.dart';
import '../screens/finished_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, this.currentIndex = 1});

  static const deepBlueAppBar = Color(0xFF021025);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: deepBlueAppBar,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color.fromARGB(179, 78, 181, 245),
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Da leggere'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_added), label: 'Finiti'),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ReadingScreen()),
            );
            break;
          case 1:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            break;
          case 2:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FinishedScreen()),
            );
            break;
        }
      },
    );
  }
}