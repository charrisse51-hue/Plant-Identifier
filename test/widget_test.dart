import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_projects/pages/welcome/welcome_page.dart';

void main() {
  testWidgets('welcome screen opens the sign-up flow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Sign Up'), findsWidgets);
  });
}
