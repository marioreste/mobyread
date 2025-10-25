import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class OpenLibraryService {
  final http.Client httpClient;
  final Map<String, _CacheEntry> _cache = {};
  final Duration cacheTtl;
  final int maxCacheEntries;

  OpenLibraryService({
    http.Client? httpClient,
    this.cacheTtl = const Duration(hours: 1),
    this.maxCacheEntries = 200,
  }) : httpClient = httpClient ?? http.Client();

  void clearCache() => _cache.clear();

  // Normalizza ISBN: rimuove spazi e trattini, mantiene X se presente (ma lo converte in maiuscolo)
  String normalizeIsbn(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
  }

  /// Verifica che la stringa sia un ISBN valido (10 o 13 cifre, con checksum corretto)
  bool isValidIsbn(String rawOrNormalized) {
    final s = normalizeIsbn(rawOrNormalized);
    if (s.length == 10) return _isValidIsbn10(s);
    if (s.length == 13) return _isValidIsbn13(s);
    return false;
  }

  bool _isValidIsbn10(String s) {
    // ISBN-10: primi 9 devono essere cifre, l'ultima può essere 0-9 o X
    if (!RegExp(r'^\d{9}[\dX]$').hasMatch(s)) return false;
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += (i + 1) * int.parse(s[i]);
    }
    final checkChar = s[9];
    final checkValue = (checkChar == 'X') ? 10 : int.parse(checkChar);
    sum += 10 * checkValue;
    return sum % 11 == 0;
  }

  bool _isValidIsbn13(String s) {
    if (!RegExp(r'^\d{13}$').hasMatch(s)) return false;
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(s[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    final check = (10 - (sum % 10)) % 10;
    final last = int.parse(s[12]);
    return check == last;
  }

  /// Restituisce Book? dato un ISBN (accetta raw con trattini/spazi).
  /// Usa la classe Book già presente nel progetto.
  Future<Book?> fetchByIsbn(String rawIsbn) async {
    final isbn = normalizeIsbn(rawIsbn);
    if (isbn.isEmpty || !isValidIsbn(isbn)) throw ArgumentError('ISBN non valido');

    final now = DateTime.now();
    final cacheKey = isbn;
    final cached = _cache[cacheKey];
    if (cached != null && now.difference(cached.ts) < cacheTtl) {
      return cached.book;
    }

    final headers = {
      'User-Agent': 'mobyread/1.0',
      'Accept': 'application/json',
    };

    // 1) Prova api/books (più strutturata)
    try {
      final uri1 = Uri.https('openlibrary.org', '/api/books', {
        'bibkeys': 'ISBN:$isbn',
        'format': 'json',
        'jscmd': 'data',
      });
      final resp1 = await httpClient.get(uri1, headers: headers).timeout(Duration(seconds: 6));
      if (resp1.statusCode == 200) {
        final Map<String, dynamic> parsed = json.decode(resp1.body);
        final key = 'ISBN:$isbn';
        if (parsed.containsKey(key) && parsed[key] is Map) {
          final Map<String, dynamic> data = parsed[key] as Map<String, dynamic>;
          final title = data['title'] as String? ?? '';
          // authors: array of {name: ...}
          final authorsList = <String>[];
          if (data['authors'] is List) {
            for (final a in data['authors'] as List) {
              if (a is Map && a['name'] is String) authorsList.add(a['name'] as String);
            }
          }
          // subjects: array of {name: ...}
          final subjectsList = <String>[];
          if (data['subjects'] is List) {
            for (final s in data['subjects'] as List) {
              if (s is Map && s['name'] is String) subjectsList.add(s['name'] as String);
            }
          }
          // Mappa su Book del progetto:
          // prendi solo il primo autore se ce n'è più di uno
          final author = authorsList.isNotEmpty ? authorsList.first : '';
          final genre = subjectsList.isNotEmpty ? subjectsList.first : '';
          final book = Book(title: title, author: author, genre: genre);
          _cache[cacheKey] = _CacheEntry(DateTime.now(), book);
          // Mantieni la dimensione della cache entro il limite
          _maintainCacheSize();
          return book;
        }
      }
    } on TimeoutException {
      // fallthrough to fallback
    } catch (_) {
      // ignora e prova fallback
    }

    // 2) Fallback: search.json
    try {
      final uri2 = Uri.https('openlibrary.org', '/search.json', {'isbn': isbn});
      final resp2 = await httpClient.get(uri2, headers: headers).timeout(Duration(seconds: 6));
      if (resp2.statusCode == 200) {
        final Map<String, dynamic> parsed = json.decode(resp2.body);
        final docs = parsed['docs'] as List<dynamic>?;
        if (docs != null && docs.isNotEmpty && docs[0] is Map<String, dynamic>) {
          final Map<String, dynamic> doc = docs[0] as Map<String, dynamic>;
          final title = doc['title'] as String? ?? '';
          final authorsList = ((doc['author_name'] as List?) ?? []).whereType<String>().toList();
          final subjectsList = ((doc['subject'] as List?) ?? []).whereType<String>().toList();
          final author = authorsList.isNotEmpty ? authorsList.join(', ') : '';
          final genre = subjectsList.isNotEmpty ? subjectsList.first : '';
          final book = Book(title: title, author: author, genre: genre);
          _cache[cacheKey] = _CacheEntry(DateTime.now(), book);
          // Mantieni la dimensione della cache entro il limite
          _maintainCacheSize();
          return book;
        }
      }
    } on TimeoutException {
      // timeout
    } catch (_) {
      // ignora
    }

    return null;
  }

  void _maintainCacheSize() {
    if (_cache.length > maxCacheEntries) {
      // Ordina le voci della cache per data (più vecchie prima)
      final sortedKeys = _cache.keys.toList()
        ..sort((k1, k2) => _cache[k1]!.ts.compareTo(_cache[k2]!.ts));
      // Rimuovi le voci più vecchie fino a rimanere entro il limite
      while (_cache.length > maxCacheEntries) {
        _cache.remove(sortedKeys.removeAt(0));
      }
    }
  }
}

class _CacheEntry {
  final DateTime ts;
  final Book book;
  _CacheEntry(this.ts, this.book);
}