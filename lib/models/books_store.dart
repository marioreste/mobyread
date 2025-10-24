import 'package:flutter/foundation.dart';
import 'book.dart';

class BooksStore {
  BooksStore._private();
  static final BooksStore instance = BooksStore._private();

  final ValueNotifier<List<Book>> toRead = ValueNotifier<List<Book>>([]);
  final ValueNotifier<List<Book>> readBooks = ValueNotifier<List<Book>>([]);

  /// aggiorna recensione e voto per un Book (sostituisce l'istanza nella lista)
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