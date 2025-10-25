import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNavBar({super.key, this.currentIndex = 1, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        if (onTap != null) onTap!(i);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Da leggere'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_added), label: 'Letti'),
      ],
    );
  }
}