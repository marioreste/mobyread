import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/books_store.dart';
import '../widgets/bottom_nav.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  static const deepBlue = Color(0xFF04122B);
  static const deepBlueAppBar = Color(0xFF021025);

  void addBook(Book book) => BooksStore.instance.addToRead(book);
  void removeBook(Book book) => BooksStore.instance.removeFromToRead(book);
  void markAsRead(Book book) => BooksStore.instance.markAsRead(book);

  Future<void> _showAddBookDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final genreCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aggiungi un libro'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Titolo'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Inserisci un titolo' : null,
                  ),
                  TextFormField(
                    controller: authorCtrl,
                    decoration: const InputDecoration(labelText: 'Autore'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Inserisci un autore' : null,
                  ),
                  TextFormField(
                    controller: genreCtrl,
                    decoration: const InputDecoration(labelText: 'Genere'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Inserisci un genere' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final title = titleCtrl.text.trim();
                  final author = authorCtrl.text.trim();
                  final genre = genreCtrl.text.trim();

                  final book = Book(title: title, author: author, genre: genre);
                  addBook(book);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        titleCtrl.dispose();
        authorCtrl.dispose();
        genreCtrl.dispose();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepBlue,
      appBar: AppBar(
        backgroundColor: deepBlueAppBar,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Libri da leggere'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder<List<Book>>(
                  valueListenable: BooksStore.instance.toRead,
                  builder: (context, books, _) {
                    if (books.isEmpty) {
                      return const Center(
                        child: Text(
                          'Ancora nessun libro da leggere. Aggiungine uno!',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...books.map((book) => Column(
                                children: [
                                  ListTile(
                                    title: Text(book.title, style: const TextStyle(color: Colors.white)),
                                    subtitle: (() {
                                      final text = [book.author, book.genre].join(' - ');
                                      return Text(text, style: const TextStyle(color: Colors.white70));
                                    })(),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.white),
                                          tooltip: 'Segna come letto',
                                          onPressed: () => markAsRead(book),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Rimuovi',
                                          onPressed: () => removeBook(book),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: Colors.white24),
                                ],
                              )).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    onPressed: _showAddBookDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 22, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Aggiungi un libro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}