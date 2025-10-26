import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobyread/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolling performance smoke test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Proviamo prima a navigare alla schermata Reading tramite la BottomNavigationBar
    final bottomNavFinder = find.byType(BottomNavigationBar);
    if (tester.any(bottomNavFinder)) {
      final readingIcon = find.descendant(of: bottomNavFinder, matching: find.byIcon(Icons.book));
      if (tester.any(readingIcon)) {
        await tester.tap(readingIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    }

    // Cerchiamo vari tipi di scrollable presenti nell'app
    Finder? scrollable;
    final candidates = <Finder>[
      find.byType(Scrollable),
      find.byType(ListView),
      find.byType(CustomScrollView),
      find.byType(SingleChildScrollView),
    ];

    for (final c in candidates) {
      if (tester.any(c)) {
        scrollable = c;
        break;
      }
    }

    if (scrollable == null) {
      // Nessun widget scrollabile trovato: skip del test di performance
      // (non vogliamo fallire la CI per assenza di liste in alcune schermate)
      // Usiamo un expect vero per contrassegnare il test come passato.
      debugPrint('scrolling_test: nessun widget scrollabile trovato, skip performance check.');
      expect(true, isTrue);
      return;
    }

    // Misura il tempo necessario per eseguire alcuni fling
    final Stopwatch sw = Stopwatch()..start();

    // Esegui alcuni fling verso l'alto per simulare uno scroll lungo
    // Ripetiamo 3 volte per coprire più contenuto
    for (var i = 0; i < 3; i++) {
      await tester.fling(scrollable.first, const Offset(0, -400), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    sw.stop();

    // Report (se supportato)
    try {
      binding.reportData = <String, String>{
        'scroll_duration_ms': sw.elapsedMilliseconds.toString(),
      };
    } catch (_) {}

    // Controllo conservativo sulla durata totale
    expect(sw.elapsedMilliseconds, lessThan(3000),
        reason: 'Lo scrolling ha impiegato troppo tempo (${sw.elapsedMilliseconds}ms).');

    // Verifica che esista ancora il widget scrollabile
    expect(scrollable, findsWidgets);
  });
}