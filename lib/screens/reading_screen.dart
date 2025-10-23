import 'package:flutter/material.dart';
import '../models/book.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final List<Book> _toRead = [];

  void addBook(Book book) {
    setState(() {
      _toRead.add(book);
    });
  }

  void removeBook(Book book) {
    setState(() {
      _toRead.removeWhere((b) => b.title == book.title);
    });
  }

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

                  final book = Book(
                    title: title,
                    author: author,
                    genre: genre,
                  );

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

    // rimanda il dispose al frame successivo così il TextFormField ha tempo di rimuovere i listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        titleCtrl.dispose();
        authorCtrl.dispose();
        genreCtrl.dispose();
      } catch (_) {
        // ignore eventuali eccezioni di dispose se già rimossi
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libri da leggere'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              // area principale con lista dei libri "da leggere"
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _toRead.isEmpty
                      ? const Center(
                          child: Text('Ancora nessun libro da leggere. Aggiungine uno!'),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ..._toRead
                                  .map(
                                    (book) => Column(
                                      children: [
                                        ListTile(
                                          title: Text(book.title),
                                          subtitle: Text(book.author),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => removeBook(book),
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ),
                ),
              ),

              // pulsante centrato in fondo: apre dialog per inserire nuovo libro
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showAddBookDialog,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text('Aggiungi un libro'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}