import 'package:flutter/material.dart';
import '../models/book.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() {
    return _ReadScreenState();
  }
}

class _ReadScreenState extends State<ReadScreen> {
  final List<Book> _read = [];

  void addBook(Book book) {
    setState(() {
      _read.add(book);
    });
  }

  void removeBook(Book book) {
    setState(() {
      _read.removeWhere((b) => b.title == book.title);
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final title = titleCtrl.text.trim();
                  final author = authorCtrl.text.trim();
                  final genre = genreCtrl.text.trim();
                  // crea l'oggetto Book usando i campi disponibili nel modello
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
    titleCtrl.dispose();
    authorCtrl.dispose();
    genreCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libri letti'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _read.isEmpty
                      ? const Center(
                          child: Text('Ancora nessun libro letto'),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ..._read
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