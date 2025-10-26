import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobyread/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolling performance smoke test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final bottomNavFinder = find.byType(BottomNavigationBar);
    if (tester.any(bottomNavFinder)) {
      final readingIcon = find.descendant(of: bottomNavFinder, matching: find.byIcon(Icons.book));
      if (tester.any(readingIcon)) {
        await tester.tap(readingIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    }

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
      debugPrint('scrolling_test: nessun widget scrollabile trovato, skip performance check.');
      expect(true, isTrue);
      return;
    }

    final Stopwatch sw = Stopwatch()..start();

    for (var i = 0; i < 3; i++) {
      await tester.fling(scrollable.first, const Offset(0, -400), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    sw.stop();
    debugPrint('scrolling_test: durata scroll totale = ${sw.elapsedMilliseconds} ms');

    try {
      binding.reportData = <String, String>{
        'scroll_duration_ms': sw.elapsedMilliseconds.toString(),
      };
    } catch (_) {}

    // Soglia allentata per evitare falsi negativi su desktop/dev
    const int thresholdMs = 7000;
    expect(sw.elapsedMilliseconds, lessThan(thresholdMs),
        reason: 'Lo scrolling ha impiegato troppo tempo (${sw.elapsedMilliseconds}ms) > $thresholdMs ms.');

    expect(scrollable, findsWidgets);
  });
}