import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/books_store.dart';

class FinishedScreen extends StatefulWidget {
  const FinishedScreen({super.key});

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  static const deepBlue = Color(0xFF04122B);
  static const deepBlueAppBar = Color(0xFF021025);

  void addBook(Book book) => BooksStore.instance.addRead(book);
  void removeBook(Book book) => BooksStore.instance.removeFromRead(book);

  Future<void> _showAddBookDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final genreCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
          'Aggiungi un libro letto',
          style: TextStyle(color: Colors.white),
          ),
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

  Future<void> _openReviewDialog(Book book) async{
    final textCtrl = TextEditingController(text: book.review ?? '');
    double? rating = book.rating;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          const double starSize = 40.0;

          Widget starWidget(int index) {
            // index 0..4 -> valori 0.5..5.0
            final fullThreshold = index + 1.0;
            final halfThreshold = index + 0.5;
            IconData icon;
            if (rating != null && rating! >= fullThreshold) {
              icon = Icons.star;
            } else if (rating != null && rating! >= halfThreshold) {
              icon = Icons.star_half;
            } else {
              icon = Icons.star_border;
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                // calcola se click è sulla metà sinistra o destra della stella
                final localDx = details.localPosition.dx;
                final isLeft = localDx < starSize / 2;
                final newRating = isLeft ? (index + 0.5) : (index + 1.0);

                // la prima stella non può essere lasciata vuota:
                final enforcedRating = newRating < 0.5 ? 0.5 : newRating;
                setState(() => rating = enforcedRating);
              },
              child: SizedBox(
                width: starSize,
                height: starSize,
                child: Center(
                  child: Icon(icon, color: Colors.amber, size: starSize - 6),
                ),
              ),
            );
          }

          return AlertDialog(
            title: Text(book.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: textCtrl,
                    minLines: 1,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: 'Recensione (opzionale)'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Voto'),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) => starWidget(i)),
                        ),
                        const SizedBox(height: 6),
                        if (rating == null)
                          const Text('Seleziona un voto!', style: TextStyle(color: Colors.red, fontSize: 12)),
                        Text(rating == null ? 'Nessun voto' : rating.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
              ElevatedButton(
                onPressed: rating == null
                    ? null
                    : () {
                        final reviewText = textCtrl.text.trim();
                        final reviewToSave = reviewText.isEmpty ? null : reviewText;
                        BooksStore.instance.updateReview(book, review: reviewToSave, rating: rating);
                        Navigator.of(context).pop();
                      },
                child: const Text('Salva'),
              ),
            ],
          );
        });
      },
    );

     WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        textCtrl.dispose();
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
        title: const Text('Libri letti'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder<List<Book>>(
                  valueListenable: BooksStore.instance.readBooks,
                  builder: (context, books, _) {
                    if (books.isEmpty) {
                      return const Center(
                        child: Text('Ancora nessun libro segnato come letto.', style: TextStyle(color: Colors.white)),
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
                                    }()),
                                    onTap: () => _openReviewDialog(book),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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
                              )),
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
                        Text('Aggiungi libro letto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}