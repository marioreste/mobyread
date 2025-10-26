import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyread/widgets/bottom_nav.dart';

void main() {
  testWidgets('BottomNavBar shows icons and calls onTap with correct index', (WidgetTester tester) async {
    int tapped = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            currentIndex: 1,
            onTap: (i) => tapped = i,
          ),
        ),
      ),
    );

    // attendi che il widget completi build/animazioni
    await tester.pumpAndSettle();

    // verifica icone presenti (coerenti con lib/widgets/bottom_nav.dart)
    expect(find.byIcon(Icons.book), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_added), findsOneWidget);

    // tap e verifica callback (usa le stesse icone)
    await tester.tap(find.byIcon(Icons.book));
    await tester.pumpAndSettle();
    expect(tapped, 0);

    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(tapped, 1);

    await tester.tap(find.byIcon(Icons.bookmark_added));
    await tester.pumpAndSettle();
    expect(tapped, 2);
  });
}