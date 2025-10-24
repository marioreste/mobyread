import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'book.dart';

class BooksStore {
  BooksStore._private();
  static final BooksStore instance = BooksStore._private();

  final ValueNotifier<List<Book>> toRead = ValueNotifier<List<Book>>([]);
  final ValueNotifier<List<Book>> readBooks = ValueNotifier<List<Book>>([]);

  late final File _toReadFile;
  late final File _readFile;
  bool _initialized = false;
  bool _saving = false;

  Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _toReadFile = File('${dir.path}/mobyread_to_read.json');
    _readFile = File('${dir.path}/mobyread_read.json');

    await _loadFromDisk();

    // salva automaticamente quando cambiano le liste
    toRead.addListener(_persistToRead);
    readBooks.addListener(_persistRead);
    _initialized = true;
  }

  Future<void> _loadFromDisk() async {
    try {
      if (await _toReadFile.exists()) {
        final s = await _toReadFile.readAsString();
        final List<dynamic> j = json.decode(s);
        toRead.value = j.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (await _readFile.exists()) {
        final s = await _readFile.readAsString();
        final List<dynamic> j = json.decode(s);
        readBooks.value = j.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Ignora errori di parsing, mantieni liste vuote
      debugPrint('BooksStore load error: $e');
    }
  }

  Future<void> _persistToRead() async {
    await _writeList(_toReadFile, toRead.value);
  }

  Future<void> _persistRead() async {
    await _writeList(_readFile, readBooks.value);
  }

  Future<void> _writeList(File file, List<Book> list) async {
    if (_saving) return; // semplice protezione: evita salvataggi paralleli rapidi
    _saving = true;
    try {
      final s = json.encode(list.map((b) => b.toJson()).toList());
      await file.writeAsString(s);
    } catch (e) {
      debugPrint('BooksStore save error: $e');
    } finally {
      _saving = false;
    }
  }

  void addToRead(Book b) => toRead.value = [...toRead.value, b];
  void removeFromToRead(Book b) => toRead.value = toRead.value.where((x) => x.title != b.title).toList();

  void addRead(Book b) => readBooks.value = [...readBooks.value, b];
  void removeFromRead(Book b) => readBooks.value = readBooks.value.where((x) => x.title != b.title).toList();

  void markAsRead(Book b) {
    removeFromToRead(b);
    addRead(b);
  }

  void updateReview(Book book, {String? review, double? rating}) {
    void _updateList(ValueNotifier<List<Book>> list) {
      final idx = list.value.indexWhere((b) => b.title == book.title && b.author == book.author);
      if (idx != -1) {
        final updated = list.value.toList();
        updated[idx] = updated[idx].copyWith(review: review, rating: rating);
        list.value = updated;
      }
    }

    _updateList(toRead);
    _updateList(readBooks);
  }
}