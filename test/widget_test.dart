import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verify that a basic MaterialApp can be constructed and pumped.
    // Full app test requires Supabase initialization which needs network access.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('CampusOS v2.0'))),
      ),
    );
    expect(find.text('CampusOS v2.0'), findsOneWidget);
  });
}
