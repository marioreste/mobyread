import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(this.switchScreen, {super.key});
  final Function(String) switchScreen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image:  AssetImage('assets/images/mobyread_logo.png')),
          const SizedBox(height: 30),
          const Text(
            'Benvenuto in MobyRead!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () => switchScreen('reading'),
            icon: const Icon(Icons.book),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.black,
            ),
            label: const Text('Vai ai libri da leggere'),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () => switchScreen('read'),
            icon: const Icon(Icons.bookmark_added),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.black,
            ),
            label: const Text('Vai ai libri letti'),
          ),
        ],
      )
    );
  }
}