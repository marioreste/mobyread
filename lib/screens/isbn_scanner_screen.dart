import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/book.dart';
import '../models/books_store.dart';
import '../services/open_library_service.dart';

class IsbnScannerScreen extends StatefulWidget {
  const IsbnScannerScreen({super.key});

  @override
  State<IsbnScannerScreen> createState() => _IsbnScannerScreenState();
}

class _IsbnScannerScreenState extends State<IsbnScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final OpenLibraryService _service = OpenLibraryService();
  bool _processing = false;
  bool _torchOn = false;

  Future<void> _resumeScanning() async {
    try {
      await _controller.start();
    } catch (_) {}
    _processing = false;
  }

  Future<void> _handleCode(String code) async {
    if (_processing) return;
    _processing = true;
    await _controller.stop();

    final normalized = _service.normalizeIsbn(code);
    if (!_service.isValidIsbn(normalized)) {
      await _showAlert('Codice non valido', 'Il codice rilevato non è un ISBN valido.');
      await _resumeScanning();
      return;
    }

    Book? book;
    try {
      // mostra indicatore di caricamento mentre cerchiamo
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      book = await _service.fetchByIsbn(normalized);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // rimuovi loading
        await _showAlert('Errore', 'Si è verificato un errore durante la ricerca. Controlla la connessione Internet e riprova.');
        await _resumeScanning();
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // rimuovi loading

    if (book == null) {
      await _showAlert('Non trovato', 'Nessun libro trovato per l\'ISBN: $normalized. Controlla la connessione Internet e riprova.');
      await _resumeScanning();
      return;
    }

    // mostra dialog di visualizzazione / modifica / aggiunta
    var current = book;
    while (mounted) {
      final action = await _showBookViewDialog(current);
      if (action == _BookDialogAction.cancel) {
        await _resumeScanning();
        return;
      } else if (action == _BookDialogAction.edit) {
        final edited = await _showEditDialog(current);
        if (edited != null) {
          current = edited;
          continue; // riapri vista con dati aggiornati
        } else {
          // se annullato nel edit, torna alla view
          continue;
        }
      } else if (action == _BookDialogAction.add) {
        final target = await _showAddChoiceDialog();
        if (target == _AddTarget.toRead) {
          BooksStore.instance.addToRead(current);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aggiunto a "Da leggere"')));
        } else if (target == _AddTarget.read) {
          BooksStore.instance.addRead(current);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aggiunto a "Letti"')));
        }
        await _resumeScanning();
        return;
      } else {
        await _resumeScanning();
        return;
      }
    }
  }

  Future<void> _showAlert(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<_BookDialogAction?> _showBookViewDialog(Book book) {
    return showDialog<_BookDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Libro trovato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Autore: ${book.author.isNotEmpty ? book.author : '—'}'),
              const SizedBox(height: 6),
              Text('Genere: ${book.genre.isNotEmpty ? book.genre : '—'}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(_BookDialogAction.cancel), child: const Text('Annulla')),
            TextButton(onPressed: () => Navigator.of(context).pop(_BookDialogAction.edit), child: const Text('Modifica')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(_BookDialogAction.add), child: const Text('Aggiungi')),
          ],
        );
      },
    );
  }

  Future<Book?> _showEditDialog(Book book) {
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    final genreController = TextEditingController(text: book.genre);

    return showDialog<Book?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica dati libro'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titolo')),
                TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Autore')),
                TextField(controller: genreController, decoration: const InputDecoration(labelText: 'Genere')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                final edited = book.copyWith(
                  title: titleController.text.trim(),
                  author: authorController.text.trim(),
                  genre: genreController.text.trim(),
                );
                Navigator.of(context).pop(edited);
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  Future<_AddTarget?> _showAddChoiceDialog() {
    return showDialog<_AddTarget>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Aggiungi a'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(_AddTarget.toRead),
              child: const Text('Da leggere'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(_AddTarget.read),
              child: const Text('Letti'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Annulla'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner ISBN'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              try {
                await _controller.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              } catch (_) {}
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final raw = barcodes.first.rawValue;
              if (raw == null) return;
              _handleCode(raw);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: const Text('Inquadra il codice a barre (EAN/ISBN)', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BookDialogAction { cancel, edit, add }
enum _AddTarget { toRead, read }