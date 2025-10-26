import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reading_screen.dart';
import 'finished_screen.dart';
import 'isbn_scanner_screen.dart';
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
                height: 280,
                child: Image.asset('assets/mobyread.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 12),
              Text(
                'Benvenuto in MobyRead!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
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
                      decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.6), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Nessuna attività recente', style: TextStyle(color: Colors.white70))),
                    );
                  }
                  return Column(
                    children: last.map((e) {
                      return Column(
                        children: [
                          ListTile(
                            tileColor: const Color.fromRGBO(255, 255, 255, 0.12),
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
              // Quick action: Scanner ISBN (sostituisce i due bottoni)
              SizedBox(
                width: buttonWidth,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<String>(
                      MaterialPageRoute(builder: (_) => const IsbnScannerScreen()),
                    );
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Codice rilevato: $result')),
                      );
                    }
                  },
                  icon: const Icon(Icons.camera_alt, size: 26),
                  label: const Text('Scanner ISBN'),
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
    );
  }
}
