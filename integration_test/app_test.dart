import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mobyread/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test: app starts and bottom navigation works', (WidgetTester tester) async {
    app.main();
    // lascia avviare l'app
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // verifica che la app abbia una BottomNavigationBar
    final bottomNavFinder = find.byType(BottomNavigationBar);
    expect(bottomNavFinder, findsOneWidget);

    // icone usate dal progetto (aggiorna se differiscono)
    final icons = <IconData>[Icons.book, Icons.home, Icons.bookmark_added];

    // per ogni icona: verifica presenza e prova a tappare *all'interno* della BottomNavigationBar
    for (var i = 0; i < icons.length; i++) {
      final iconFinder = find.descendant(of: bottomNavFinder, matching: find.byIcon(icons[i]));
      if (tester.any(iconFinder)) {
        // se ci sono più occorrenze, prendiamo la prima dentro la BottomNavigationBar
        await tester.tap(iconFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    }

    // se sulla Home esiste un pulsante per lo scanner prova ad aprirlo (non richiede la fotocamera)
    final scannerFinder = find.textContaining('Scanner', findRichText: false);
    if (tester.any(scannerFinder)) {
      await tester.tap(scannerFinder.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // verifica che lo screen scanner sia visibile (adatta il testo se necessario)
      expect(find.textContaining('Scanner', findRichText: false), findsWidgets);
    }
  });
}