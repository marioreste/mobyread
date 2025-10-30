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

  String normalizeIsbn(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
  }

  bool isValidIsbn(String rawOrNormalized) {
    final s = normalizeIsbn(rawOrNormalized);
    if (s.length == 10) return _isValidIsbn10(s);
    if (s.length == 13) return _isValidIsbn13(s);
    return false;
  }

  bool _isValidIsbn10(String s) {
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
          final authorsList = <String>[];
          if (data['authors'] is List) {
            for (final a in data['authors'] as List) {
              if (a is Map && a['name'] is String) authorsList.add(a['name'] as String);
            }
          }
          final subjectsList = <String>[];
          if (data['subjects'] is List) {
            for (final s in data['subjects'] as List) {
              if (s is Map && s['name'] is String) subjectsList.add(s['name'] as String);
            }
          }
          final author = authorsList.isNotEmpty ? authorsList.first : '';
          final genre = subjectsList.isNotEmpty ? subjectsList.first : '';
          final book = Book(title: title, author: author, genre: genre);
          _cache[cacheKey] = _CacheEntry(DateTime.now(), book);
          _maintainCacheSize();
          return book;
        }
      }
    } on TimeoutException {
    } catch (_) {
    }

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
          _maintainCacheSize();
          return book;
        }
      }
    } on TimeoutException {
    } catch (_) {
    }

    return null;
  }

  void _maintainCacheSize() {
    if (_cache.length > maxCacheEntries) {
      final sortedKeys = _cache.keys.toList()
        ..sort((k1, k2) => _cache[k1]!.ts.compareTo(_cache[k2]!.ts));
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