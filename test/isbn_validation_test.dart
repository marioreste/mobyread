import 'package:test/test.dart';
import 'package:mobyread/services/open_library_service.dart';

void main() {
  final svc = OpenLibraryService();

  group('OpenLibraryService.isValidIsbn', () {
    test('valid ISBN-13 and normalization with hyphens', () {
      expect(svc.isValidIsbn('9780306406157'), isTrue);
      expect(svc.isValidIsbn('978-0-306-40615-7'), isTrue);
    });

    test('valid ISBN-10 and normalization with hyphens', () {
      expect(svc.isValidIsbn('0306406152'), isTrue);
      expect(svc.isValidIsbn('0-306-40615-2'), isTrue);
    });

    test('invalid ISBNs are rejected', () {
      expect(svc.isValidIsbn('12345'), isFalse);
      expect(svc.isValidIsbn('9780306406158'), isFalse); // bad checksum
    });
  });
}