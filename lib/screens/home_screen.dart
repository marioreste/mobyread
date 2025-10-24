import 'package:flutter/material.dart';
import 'reading_screen.dart';
import 'finished_screen.dart';
import '../widgets/bottom_nav.dart';
import '../models/books_store.dart';
import '../models/book.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const deepBlue = Color(0xFF04122B);
  static const deepBlueAppBar = Color(0xFF021025);

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 320.0;

    return Scaffold(
      backgroundColor: deepBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Image.asset('assets/whale.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 12),
              const Text(
                'Benvenuto in MobyRead!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 18),

              // Dashboard: counts + avg rating
              ValueListenableBuilder<List<Book>>(
                valueListenable: BooksStore.instance.toRead,
                builder: (context, toReadList, _) {
                  return ValueListenableBuilder<List<Book>>(
                    valueListenable: BooksStore.instance.readBooks,
                    builder: (context, readList, _) {
                      final toReadCount = toReadList.length;
                      final readCount = readList.length;
                      // media basata solo su libri con rating non-null
                      final rated = readList.where((b) => b.rating != null).toList();
                      final avg = rated.isEmpty ? null : (rated.map((b) => b.rating!).reduce((a, b) => a + b) / rated.length);

                      return Row(
                        children: [
                          StatCard(
                            value: '$toReadCount',
                            icon: Icons.book,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReadingScreen())),
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            value: '$readCount',
                            icon: Icons.bookmark_added,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinishedScreen())),
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            value: avg == null ? 'N/D' : avg.toStringAsFixed(1),
                            icon: Icons.star,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinishedScreen())),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 22),

              // Recent events
              Align(alignment: Alignment.centerLeft, child: Text('Ultime attività', style: TextStyle(color: Colors.white70, fontSize: 16))),
              const SizedBox(height: 8),
              ValueListenableBuilder<List<String>>(
                valueListenable: BooksStore.instance.recentEvents,
                builder: (context, events, _) {
                  final last = events.take(3).toList();
                  if (last.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Nessuna attività recenti', style: TextStyle(color: Colors.white70))),
                    );
                  }
                  return Column(
                    children: last.map((e) {
                      return Column(
                        children: [
                          ListTile(
                            tileColor: Colors.white.withOpacity(0.04),
                            title: Text(e, style: const TextStyle(color: Colors.white70)),
                            leading: const Icon(Icons.history, color: Colors.white70),
                            dense: true,
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),
              // Quick actions (keeps welcome buttons for compatibility)
              SizedBox(
                width: buttonWidth,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReadingScreen())),
                  icon: const Icon(Icons.book, size: 26),
                  label: const Text('Vai ai libri da leggere'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: buttonWidth,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinishedScreen())),
                  icon: const Icon(Icons.bookmark_added, size: 26),
                  label: const Text('Vai ai libri letti'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
