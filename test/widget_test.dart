// Basic smoke test for TOFAN AI.
//
// Verifies that the app boots and shows the bottom navigation shell.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/main.dart';

void main() {
  testWidgets('App boots and shows Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TofanAiApp()));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Welcome to TOFAN AI'), findsOneWidget);
  });
}
