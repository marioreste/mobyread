import 'package:flutter/foundation.dart';
import 'book.dart';

class BooksStore {
  BooksStore._private();
  static final BooksStore instance = BooksStore._private();

  // liste osservabili
  final ValueNotifier<List<Book>> toRead = ValueNotifier<List<Book>>([]);
  final ValueNotifier<List<Book>> readBooks = ValueNotifier<List<Book>>([]);

  void addToRead(Book b) {
    toRead.value = [...toRead.value, b];
  }

  void removeFromToRead(Book b) {
    toRead.value = toRead.value.where((x) => x.title != b.title).toList();
  }

  void addRead(Book b) {
    readBooks.value = [...readBooks.value, b];
  }

  void removeFromRead(Book b) {
    readBooks.value = readBooks.value.where((x) => x.title != b.title).toList();
  }

  // helper: sposta da toRead a readBooks
  void markAsRead(Book b) {
    removeFromToRead(b);
    addRead(b);
  }
}