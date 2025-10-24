import 'package:flutter/material.dart';
import 'reading_screen.dart';
import 'finished_screen.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const deepBlue = Color(0xFF04122B);

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 320.0;

    return Scaffold(
      backgroundColor: deepBlue,
      body: Container(
        width: double.infinity,
        color: deepBlue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                child: Image.asset(
                  'assets/whale.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Benvenuto in MobyRead!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: buttonWidth,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReadingScreen()),
                    );
                  },
                  icon: const Icon(Icons.book, size: 26),
                  label: const Text(
                    'Vai ai libri da leggere',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: buttonWidth,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FinishedScreen()),
                    );
                  },
                  icon: const Icon(Icons.bookmark_added, size: 26),
                  label: const Text(
                    'Vai ai libri letti',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
