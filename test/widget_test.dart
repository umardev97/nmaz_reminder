import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmaz_reminder/core/theme.dart';

void main() {
  testWidgets('premium theme renders primary action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Continue'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
